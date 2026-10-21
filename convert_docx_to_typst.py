import zipfile
import xml.etree.ElementTree as ET
import os
import re

docx_path = "/var/home/ocelot/Repositories/isaiasdocs/Documento_final_INTV.docx"
content_dir = "/var/home/ocelot/Repositories/isaiasdocs/content"
os.makedirs(content_dir, exist_ok=True)

with zipfile.ZipFile(docx_path, "r") as z:
    doc_xml = z.read("word/document.xml")
    root = ET.fromstring(doc_xml)
    ns = {
        "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
        "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
        "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    }
    rels_xml = z.read("word/_rels/document.xml.rels")
    rels_root = ET.fromstring(rels_xml)
    rel_map = {rel.attrib["Id"]: rel.attrib["Target"] for rel in rels_root}
    body = root.find(".//w:body", ns)

    elements = []
    for idx, child in enumerate(body):
        tag = child.tag.split("}")[-1]
        if tag == "p":
            runs_data = []
            for r in child.findall(".//w:r", ns):
                t_list = [t.text for t in r.findall(".//w:t", ns) if t.text]
                if not t_list:
                    continue
                t_str = "".join(t_list)
                b = r.find(".//w:b", ns) is not None
                i = r.find(".//w:i", ns) is not None
                runs_data.append({"text": t_str, "bold": b, "italic": i})
            
            blips = child.findall(".//a:blip", ns)
            imgs = [rel_map.get(b.attrib.get("{http://schemas.openxmlformats.org/officeDocument/2006/relationships}embed"), "unknown") for b in blips]
            
            pStyle = child.find(".//w:pPr/w:pStyle", ns)
            style = pStyle.attrib.get("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val") if pStyle is not None else ""
            
            numPr = child.find(".//w:pPr/w:numPr", ns)
            is_num = numPr is not None or style == "Prrafodelista"
            
            full_text = "".join(r["text"] for r in runs_data).strip()
            all_bold = bool(runs_data) and all(r["bold"] for r in runs_data if r["text"].strip())
            
            elements.append({
                "idx": idx,
                "tag": "p",
                "text": full_text,
                "runs": runs_data,
                "images": imgs,
                "style": style,
                "is_bold": all_bold,
                "is_list": is_num
            })
        elif tag == "tbl":
            table_rows = []
            for row in child.findall(".//w:tr", ns):
                cells = []
                for cell in row.findall(".//w:tc", ns):
                    c_texts = [t.text for t in cell.findall(".//w:t", ns) if t.text]
                    cells.append(" ".join("".join(c_texts).split()))
                table_rows.append(cells)
            elements.append({
                "idx": idx,
                "tag": "tbl",
                "rows": table_rows
            })

def coalesce_runs(runs):
    if not runs:
        return []
    merged = []
    current = runs[0].copy()
    for r in runs[1:]:
        if r["bold"] == current["bold"] and r["italic"] == current["italic"]:
            current["text"] += r["text"]
        else:
            merged.append(current)
            current = r.copy()
    merged.append(current)
    return merged

def format_typst_paragraph(elem):
    if elem.get("images"):
        lines = []
        for img in elem["images"]:
            filename = os.path.basename(img)
            caption = elem["text"].strip()
            if caption:
                cap_esc = caption.replace("#", "\\#").replace("$", "\\$").replace("*", "\\*")
                cap_esc = re.sub(r"<(?=\d)", "< ", cap_esc)
                cap_esc = re.sub(r"<(?=[a-zA-Z_])", "\\<", cap_esc)
                lines.append(f'#figure(image("../images/{filename}", width: 92%), caption: [{cap_esc}])\n')
            else:
                lines.append(f'#align(center)[#image("../images/{filename}", width: 92%)]\n')
        return "\n".join(lines)
    
    runs = elem.get("runs", [])
    if not runs:
        return ""
    
    coalesced = coalesce_runs(runs)
    parts = []
    for idx, r in enumerate(coalesced):
        t = r["text"]
        t = t.replace("#", "\\#").replace("$", "\\$")
        t = re.sub(r"<(?=\d)", "< ", t)
        t = re.sub(r"<(?=[a-zA-Z_])", "\\<", t)
        
        if r["bold"] and r["italic"]:
            core = t.strip()
            if core:
                prefix = " " if (parts and not parts[-1].endswith((" ", "\n", "(", "["))) else ""
                if core.endswith(":"):
                    suffix = " "
                elif idx < len(coalesced) - 1 and not coalesced[idx+1]["bold"] and not coalesced[idx+1]["text"].startswith((" ", ":", ",", ".")):
                    suffix = ": "
                else:
                    suffix = " " if t.endswith(" ") else ""
                parts.append(f"{prefix}_*{core}*_{suffix}")
        elif r["bold"]:
            core = t.strip()
            if core:
                prefix = " " if (parts and not parts[-1].endswith((" ", "\n", "(", "["))) else ""
                if "Descripción" in core and parts and "Funciones utilizadas" in parts[0]:
                    prefix = " \\\n"
                if core.endswith(":"):
                    suffix = " "
                elif idx < len(coalesced) - 1 and not coalesced[idx+1]["bold"] and not coalesced[idx+1]["text"].startswith((" ", ":", ",", ".")):
                    suffix = ": "
                else:
                    suffix = " " if t.endswith(" ") else ""
                parts.append(f"{prefix}*{core}*{suffix}")
        elif r["italic"]:
            core = t.strip()
            if core:
                prefix = " " if (parts and not parts[-1].endswith((" ", "\n", "(", "["))) else ""
                suffix = " " if t.endswith(" ") else ""
                parts.append(f"{prefix}_{core}_{suffix}")
        else:
            t = t.replace("*", "\\*")
            parts.append(t)
            
    return "".join(parts).strip()

def format_table(rows):
    if not rows or not rows[0]:
        return ""
    cols_count = len(rows[0])
    lines = []
    lines.append(f"#align(center)[#table(")
    lines.append(f"  columns: {cols_count},")
    lines.append(f"  align: (center, left, ..(right,) * {cols_count - 2}),")
    lines.append(f"  stroke: 0.5pt + luma(180),")
    lines.append(f"  fill: (col, row) => if row == 0 {{ rgb(\"eef2f7\") }} else if calc.even(row) {{ rgb(\"fafbfc\") }} else {{ none }},")
    
    for r_idx, row in enumerate(rows):
        cells_typst = []
        for cell in row:
            c_esc = cell.replace("#", "\\#").replace("$", "\\$").replace("*", "\\*")
            c_esc = re.sub(r"<(?=\d)", "< ", c_esc)
            c_esc = re.sub(r"<(?=[a-zA-Z_])", "\\<", c_esc)
            if r_idx == 0:
                cells_typst.append(f"[*_{c_esc}_*]")
            else:
                cells_typst.append(f"[{c_esc}]")
        lines.append(f"  {', '.join(cells_typst)},")
    lines.append(")]\n")
    return "\n".join(lines)

def process_section_1():
    out = []
    for elem in elements[28:87]:
        if elem["tag"] == "p":
            txt = elem["text"]
            if not txt:
                continue
            if txt == "Introducción":
                out.append("= Introducción\n\n")
            elif txt == "Objetivos del proyecto":
                out.append("== Objetivos del Proyecto\n\n")
            elif txt == "General:":
                out.append("=== Objetivo General\n\n")
            elif txt == "Específicos:":
                out.append("=== Objetivos Específicos\n\n")
            elif txt == "Contexto del problema":
                out.append("== Contexto del Problema\n\n")
            elif txt == "Planteamiento del problema":
                out.append("== Planteamiento del Problema\n\n")
            elif txt.startswith("Se parte de la hipótesis"):
                out.append("== Hipótesis y Limitaciones\n\n")
                out.append(format_typst_paragraph(elem) + "\n\n")
            elif elem["is_list"] or elem["idx"] in [48, 50, 52]:
                out.append(f"- {format_typst_paragraph(elem)}\n")
            else:
                out.append(format_typst_paragraph(elem) + "\n\n")
    return "".join(out)

def process_section_2():
    out = []
    for elem in elements[87:556]:
        if elem["tag"] == "tbl":
            out.append(format_table(elem["rows"]) + "\n")
            continue
        txt = elem["text"]
        if not txt and not elem.get("images"):
            continue
        
        if elem.get("images"):
            out.append(format_typst_paragraph(elem) + "\n")
            continue
        
        if txt == "Marco Teórico":
            out.append("= Marco Teórico\n\n")
        elif txt == "Metodología":
            out.append("= Metodología\n\n")
        elif txt in ["Población y muestra", "Fases del estudio", "Infraestructura Tecnológica", "Descripción de la base de datos", "Descripción de variables", "Herramientas"]:
            out.append(f"== {txt}\n\n")
        elif txt in ["Computación en la Nube (Cloud Computing)", "Aprovisionamiento de Infraestructura mediante Terraform", "Proceso de Despliegue de la Infraestructura", "Recursos Implementados en Azure", "Especificaciones de las Tablas", "2. Matriz de Módulos Clínicos y de Laboratorio", "Funciones y cláusulas de SQL Server", "Herramientas metodológicas (métodos matemáticos y estadísticos)", "Herramientas computacionales"]:
            out.append(f"=== {txt}\n\n")
        elif txt.startswith("Modelo de Regresión Logística Bayesiana"):
            out.append(f"== Modelación Matemática y Métodos Bayesianos\n\n")
            out.append(f"=== {txt}\n\n")
        elif elem["is_bold"] and (txt.startswith("Tabla ") or txt in ["Main.tf", "Provider.tf", "Variables.tf", "Terraform.tfvars", "Outputs.tf", "Terraform Init", "Terraform Plan", "Terraform Apply", "Grupo de Recursos (Resource Group)", "Azure Data Lake Storage Gen2", "Zona Raw", "Zona Processed", "Zona Curated", "Azure SQL Server", "Azure SQL Database", "Azure SQL Firewall Rule", "Azure Data Factory"] or re.match(r"^\d+\.\s+\w+", txt)):
            if re.match(r"^\d+\.\s+\w+", txt):
                out.append(f"=== {txt}\n\n")
            else:
                out.append(f"==== {txt}\n\n")
        elif elem["is_bold"] and txt in ["AVG()", "COUNT()", "MAX()", "MIN()", "ROUND()", "SUM()", "CASE", "OVER(PARTITION BY)", "GROUP BY", "HAVING", "WHERE", "INNER JOIN (JOIN)", "UNION ALL", "ORDER BY"]:
            out.append(f"==== Cláusula / Función `{txt}`\n\n")
        elif elem["is_bold"] and txt == "Valores normales:":
            out.append(f"*{txt}* ")
        elif elem["is_list"]:
            out.append(f"- {format_typst_paragraph(elem)}\n")
        else:
            out.append(format_typst_paragraph(elem) + "\n\n")
    return "".join(out)

def process_section_3():
    out = []
    for elem in elements[556:882]:
        if elem["tag"] == "tbl":
            out.append(format_table(elem["rows"]) + "\n")
            continue
        txt = elem["text"]
        if not txt and not elem.get("images"):
            continue
        
        if elem.get("images"):
            out.append(format_typst_paragraph(elem) + "\n")
            continue
        
        if txt == "Resultados":
            out.append("= Resultados\n\n")
        elif txt in ["Ingestión de datos de CSV a SQL Server con Python", "Exportación de datos de SQL Server a CSV con Python", "Consultas", "Interpretación y Clasificación de las Variables", "Aplicación del Modelo Bayesiano", "Resultados obtenidos"]:
            if txt == "Consultas":
                out.append("== Consultas Analíticas en SQL Server\n\n")
            elif txt == "Resultados obtenidos":
                out.append("== Resultados de los Modelos Bayesianos\n\n")
            else:
                out.append(f"== {txt}\n\n")
        elif txt in ["Resultados del Modelo Bayesiano para Consumo de Alcohol", "Resultados del Modelo Bayesiano para Tabaquismo", "Interpretación de las variables más relevantes", "Aportación a la toma de decisiones"]:
            out.append(f"=== {txt}\n\n")
        elif elem["is_bold"] and elem["style"] in ["Prrafodelista", "NormalWeb"]:
            out.append(f"=== {txt}\n\n")
        elif elem["is_bold"] and len(txt) < 80 and not txt.endswith("."):
            out.append(f"==== {txt}\n\n")
        elif elem["is_list"]:
            out.append(f"- {format_typst_paragraph(elem)}\n")
        else:
            out.append(format_typst_paragraph(elem) + "\n\n")
    return "".join(out)

def process_section_4():
    out = []
    for elem in elements[882:905]:
        if elem["tag"] == "tbl":
            out.append(format_table(elem["rows"]) + "\n")
            continue
        txt = elem["text"]
        if not txt:
            continue
        if txt == "Conclusiones":
            out.append("= Conclusiones\n\n")
        elif elem["is_list"]:
            out.append(f"- {format_typst_paragraph(elem)}\n")
        else:
            out.append(format_typst_paragraph(elem) + "\n\n")
    return "".join(out)

def process_section_5():
    out = []
    for elem in elements[905:]:
        if elem["tag"] == "tbl":
            out.append(format_table(elem["rows"]) + "\n")
            continue
        txt = elem["text"]
        if not txt:
            continue
        if txt == "Referencias":
            out.append("= Referencias Bibliográficas\n\n")
        else:
            out.append(f"- {format_typst_paragraph(elem)}\n\n")
    return "".join(out)

with open(os.path.join(content_dir, "01_introduccion.typ"), "w", encoding="utf-8") as f:
    f.write(process_section_1())
print("Updated content/01_introduccion.typ")

with open(os.path.join(content_dir, "02_metodologia.typ"), "w", encoding="utf-8") as f:
    f.write(process_section_2())
print("Updated content/02_metodologia.typ")

with open(os.path.join(content_dir, "03_resultados.typ"), "w", encoding="utf-8") as f:
    f.write(process_section_3())
print("Updated content/03_resultados.typ")

with open(os.path.join(content_dir, "04_conclusiones.typ"), "w", encoding="utf-8") as f:
    f.write(process_section_4())
print("Updated content/04_conclusiones.typ")

with open(os.path.join(content_dir, "referencias.typ"), "w", encoding="utf-8") as f:
    f.write(process_section_5())
print("Updated content/referencias.typ")
