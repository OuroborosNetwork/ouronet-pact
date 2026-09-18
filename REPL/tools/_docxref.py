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
from docx.enum.style import WD_STYLE_TYPE
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

# --- PAGE-BREAK BEHAVIOUR ---------------------------------------------------------------------
# Word's default is to break wherever the page runs out, which strands a heading alone at the foot
# of a page, splits a code block across the fold, and leaves single orphaned lines. All four rules
# below cost pages and buy readability; the owner asked for that trade explicitly.
#
#   widowControl   no single line of a paragraph is left alone at the top or bottom of a page
#   keepNext       a heading is never the last thing on a page -- it moves with its first paragraph
#   keepLines      the paragraph is never split at all; if it does not fit, the WHOLE thing moves
#   pageBreakBefore  every chapter (Heading 1) starts on a fresh page
#
# keepLines is applied to CODE and headings, not to body text. On body text it forbids any
# paragraph from spanning a page, so a 30-line paragraph arriving 5 lines from the bottom pushes a
# near-empty page. Measured both ways; see the table in Audit/README.md. Widow/orphan control is
# what typesetting actually uses for prose, and it is what removes the "split mid-sentence with one
# line left behind" case the owner described.
KEEP_WITH_NEXT = ["Heading 1", "Heading 2", "Heading 3", "Heading 4", "Heading 5", "Heading 6",
                  "Title", "Subtitle", "Image Caption", "Table Caption", "Caption",
                  "Definition Term"]
NEVER_SPLIT = ["Source Code", "Heading 1", "Heading 2", "Heading 3", "Heading 4", "Heading 5",
               "Heading 6", "Title", "Subtitle", "Table Caption", "Image Caption", "Caption"]
CHAPTER_STYLE = "Heading 1"

# The BODY styles pandoc actually emits, counted from a built book:
#   Compact 3473 · BodyText 716 · FirstParagraph 444 · BlockText 173
# Setting widow control on `Normal` alone is not enough to reach them reliably, so they are set
# explicitly. This list was MEASURED from the output, not guessed -- an earlier version of this
# script set four style names of which one did not exist, and the `except KeyError` around it meant
# code blocks silently got no page-break protection at all. That is the defect the owner was
# looking at when they asked why code was splitting across pages.
BODY_STYLES = ["Normal", "Compact", "Body Text", "First Paragraph", "Block Text"]

# Pandoc's default reference.docx does NOT define a code-block style -- it injects `SourceCode`
# into the OUTPUT when it meets a code block. A rule set on a style that is not in the reference
# therefore reaches nothing. It has to be created here for pandoc to pick ours up instead.
CODE_STYLE = "Source Code"


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

    # tighten body text, and stop paragraphs stranding single lines across the fold
    try:
        n = doc.styles["Normal"]
        n.font.size = Pt(BODY_PT)
        n.paragraph_format.line_spacing = LINE_SPACING
        n.paragraph_format.space_after = Pt(4)
        n.paragraph_format.widow_control = True
    except KeyError:
        pass

    # Create the code-block style if the reference lacks it (it does), so the keep rule below has
    # something to attach to. python-docx derives the styleId from the name by removing spaces,
    # giving `SourceCode` -- which is exactly what pandoc writes into w:pStyle.
    if CODE_STYLE not in {st.name for st in doc.styles}:
        cs = doc.styles.add_style(CODE_STYLE, WD_STYLE_TYPE.PARAGRAPH)
        cs.font.name = "Consolas"
        cs.font.size = Pt(BODY_PT - 2)
        cs.paragraph_format.space_after = Pt(6)

    # NO SILENT MISSES. A style named here that does not exist is a bug in this list, and the
    # previous version swallowed exactly that case -- so every miss is collected and raised.
    missing = []

    def _pf(name):
        names = {st.name: st for st in doc.styles}
        st = names.get(name)
        if st is None or not hasattr(st, "paragraph_format"):
            missing.append(name)
            return None
        return st.paragraph_format

    for name in KEEP_WITH_NEXT:
        pf = _pf(name)
        if pf is not None:
            pf.keep_with_next = True
            pf.widow_control = True

    for name in NEVER_SPLIT:
        pf = _pf(name)
        if pf is not None:
            pf.keep_together = True

    for name in BODY_STYLES:
        pf = _pf(name)
        if pf is not None:
            pf.widow_control = True

    pf = _pf(CHAPTER_STYLE)
    if pf is not None:
        pf.page_break_before = True

    if missing:
        raise SystemExit(
            "_docxref: these styles were named but do not exist as paragraph styles in the\n"
            "reference document, so their rules would reach nothing:\n   "
            + "\n   ".join(sorted(set(missing)))
            + "\nFix the list at the top of this script -- do not silence it.")
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
    for name in ("Heading 1", "Heading 2"):
        try:
            if not d.styles[name].paragraph_format.keep_with_next:
                bad.append(f"{name}: keep_with_next is not set")
        except KeyError:
            bad.append(f"{name}: style missing")
    try:
        if not d.styles[CHAPTER_STYLE].paragraph_format.page_break_before:
            bad.append(f"{CHAPTER_STYLE}: page_break_before is not set")
    except KeyError:
        pass
    names = {st.name: st for st in d.styles}
    for nm in BODY_STYLES:
        st = names.get(nm)
        if st is None:
            bad.append(f"{nm}: style missing from reference")
        elif not st.paragraph_format.widow_control:
            bad.append(f"{nm}: widow_control is not set")
    cs = names.get(CODE_STYLE)
    if cs is None:
        bad.append(f"{CODE_STYLE}: style missing -- code blocks will split across pages")
    elif not cs.paragraph_format.keep_together:
        bad.append(f"{CODE_STYLE}: keep_together is not set")
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
          f"PAGE of NUMPAGES footer, widow control, headings kept with their text, "
          f"chapters on fresh pages")
    return 0


if __name__ == "__main__":
    if "--check" in sys.argv:
        sys.exit(check())
    p = build()
    print(f"wrote {os.path.relpath(p, ROOT)}")
    sys.exit(check())
