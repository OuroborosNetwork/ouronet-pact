#!/usr/bin/env python3
"""_docxref.py -- build the pandoc reference.docx that gives the Audit Book its page layout.

WHY A SCRIPT AND NOT A CHECKED-IN BINARY NOBODY CAN DIFF. Pandoc takes page geometry and
headers/footers from a reference .docx, not from command-line flags -- so "thin margins with page
numbers" is a property of a 10 KB zip of XML. A binary like that, committed once and hand-edited in
Word later, is exactly the artefact this project has been removing all week: nobody can see what it
says, a diff shows `Binary files differ`, and it drifts from the thing it is supposed to control.

So it is GENERATED, from pandoc's own default reference doc, by the code below. The layout
decisions are readable, and regenerating is one command.

  python3 REPL/tools/_docxref.py           build Audit/book/reference.docx
  python3 REPL/tools/_docxref.py --check   exit 1 if it is missing or its geometry has drifted
"""
import os
import subprocess
import sys

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "Audit", "book", "reference.docx")

# --- the layout decisions, in one place ----------------------------------------------------
# 1.1 cm ~= 0.43". Narrow enough to gain roughly a fifth more text per page than the 2.54 cm
# default, wide enough that a duplex print does not lose characters in the gutter. Body text is
# dropped a point and leading tightened for the same reason: this is an 8,800-line reference
# document, and a page count that a reader has to page through is a real cost.
MARGIN_CM = 1.1
# Page size is set EXPLICITLY. Pandoc's default reference doc leaves it unset, so the page is
# whatever the reader's Word/LibreOffice locale defaults to -- Letter in the US, A4 elsewhere. A
# document that paginates differently depending on who opens it cannot have a stable page count,
# and the footer here prints one. A4; change these two constants for Letter (21.59 x 27.94).
PAGE_W_CM = 21.0
PAGE_H_CM = 29.7
BODY_PT = 10
LINE_SPACING = 1.06


def _field(run, instr):
    """Insert a Word field code (PAGE / NUMPAGES) into a run.

    A field is three child elements, not text: begin, the instruction, end. Writing the literal
    string "1" instead would produce a document whose every page is numbered 1 -- which looks
    correct in a viewer until the second page.
    """
    b = OxmlElement("w:fldChar"); b.set(qn("w:fldCharType"), "begin")
    i = OxmlElement("w:instrText"); i.set(qn("xml:space"), "preserve"); i.text = instr
    e = OxmlElement("w:fldChar"); e.set(qn("w:fldCharType"), "end")
    run._r.append(b); run._r.append(i); run._r.append(e)


def build():
    src = os.path.join(ROOT, "REPL", "tools", ".ref-default.docx")
    with open(src, "wb") as fh:
        fh.write(subprocess.run(["pandoc", "--print-default-data-file", "reference.docx"],
                                capture_output=True, check=True).stdout)
    doc = Document(src)
    os.remove(src)

    for s in doc.sections:
        s.page_width = Cm(PAGE_W_CM)
        s.page_height = Cm(PAGE_H_CM)
        s.top_margin = s.bottom_margin = Cm(MARGIN_CM)
        s.left_margin = s.right_margin = Cm(MARGIN_CM)
        s.header_distance = Cm(0.6)
        s.footer_distance = Cm(0.6)

        # PAGE NUMBERS. footer.is_linked_to_previous must be cleared first or the paragraph is
        # written into a footer the section does not actually use.
        s.footer.is_linked_to_previous = False
        p = s.footer.paragraphs[0] if s.footer.paragraphs else s.footer.add_paragraph()
        p.text = ""
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(); _field(r, "PAGE")
        p.add_run(" of ")
        r2 = p.add_run(); _field(r2, "NUMPAGES")
        for run in p.runs:
            run.font.size = Pt(8)

        s.header.is_linked_to_previous = False
        hp = s.header.paragraphs[0] if s.header.paragraphs else s.header.add_paragraph()
        hp.text = "The Ouronet Audit Book"
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        for run in hp.runs:
            run.font.size = Pt(8)
            run.font.color.rgb = None

    # tighten body text
    try:
        n = doc.styles["Normal"]
        n.font.size = Pt(BODY_PT)
        n.paragraph_format.line_spacing = LINE_SPACING
        n.paragraph_format.space_after = Pt(4)
    except KeyError:
        pass
    # code blocks a touch smaller again -- this book is full of them and they must not wrap
    for sname in ("Source Code", "Verbatim Char", "Code"):
        try:
            doc.styles[sname].font.size = Pt(BODY_PT - 2)
        except KeyError:
            pass

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    doc.save(OUT)
    return OUT


def check():
    if not os.path.exists(OUT):
        print("reference.docx: MISSING -- build with python3 REPL/tools/_docxref.py")
        return 1
    d = Document(OUT)
    s = d.sections[0]
    bad = []
    for name, got in (("top", s.top_margin), ("bottom", s.bottom_margin),
                      ("left", s.left_margin), ("right", s.right_margin)):
        if got is None or abs(got.cm - MARGIN_CM) > 0.02:
            bad.append(f"{name} margin = {got.cm if got else None}, want {MARGIN_CM}")
    for name, got, want in (("page width", s.page_width, PAGE_W_CM),
                            ("page height", s.page_height, PAGE_H_CM)):
        if got is None or abs(got.cm - want) > 0.05:
            bad.append(f"{name} = {got.cm if got else None}, want {want}")
    xml = s.footer.paragraphs[0]._p.xml if s.footer.paragraphs else ""
    if "PAGE" not in xml:
        bad.append("footer carries no PAGE field")
    if "NUMPAGES" not in xml:
        bad.append("footer carries no NUMPAGES field")
    if bad:
        print("reference.docx has DRIFTED:")
        for b in bad:
            print("   " + b)
        return 1
    print(f"docx reference: clean -- A4 {PAGE_W_CM}x{PAGE_H_CM} cm, {MARGIN_CM} cm margins, "
          f"footer carries PAGE of NUMPAGES")
    return 0


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(check())
    p = build()
    print(f"wrote {os.path.relpath(p, ROOT)}")
    sys.exit(check())
