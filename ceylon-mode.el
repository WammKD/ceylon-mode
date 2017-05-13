;;; ceylon-mode.el --- Major mode for editing Ceylon source code

;;; Copyright (C) 2015-2016 Lucas Werkmeister

;; Author: Lucas Werkmeister <mail@lucaswerkmeister.de>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Features:
;; * syntax highlighting
;; * indentation

;;; Code:

(defvar ceylon-mode-hook nil)

(defvar ceylon-mode-map
  (let ((map (make-keymap)))
;;   (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for Ceylon major mode.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ceylon\\'" . ceylon-mode))

(defconst ceylon-font-lock-string
  (list
   ;; highlighting strings with regexes, because Emacs' proper model (syntax table) isn't flexible enough to suppport string templates or verbatim strings
   '("\\(\"\"\"\\(?:[^\"]\\|\"[^\"]\\|\"\"[^\"]\\)*\"\"\"\\)" . font-lock-string-face) ; verbatim string literal
   '("\\(\\(?:\"\\|``\\)\\(?:`\\(?:[^`\"\\]\\|\\\\.\\)\\|[^`\"\\]\\|\\\\.\\)*\\(?:\"\\|``\\)\\)" . font-lock-string-face) ; string literal or string part
   '("\\('\\(?:[^'\\]\\|\\\\.\\)*'\\)" . font-lock-string-face)) ; character literal
  "Syntax highlighting for Ceylon strings.")
;; optimized regular expressions
;; don't forget to add \\< \\> around the regexp
;;(regexp-opt '("assembly" "module" "package" "import"
;;              "alias" "class" "interface" "object" "given" "value" "assign" "void" "function" "new"
;;              "of" "extends" "satisfies" "abstracts"
;;              "in" "out"
;;              "return" "break" "continue" "throw"
;;              "assert" "dynamic"
;;              "if" "else" "switch" "case" "for" "while" "try" "catch" "finally" "then" "let"
;;              "this" "outer" "super"
;;              "is" "exists" "nonempty"
;;              ) t)
(defconst ceylon-font-lock-keywords
  (list
   '("\\<\\(a\\(?:bstracts\\|lias\\|ss\\(?:e\\(?:mbly\\|rt\\)\\|ign\\)\\)\\|break\\|c\\(?:a\\(?:se\\|tch\\)\\|lass\\|ontinue\\)\\|dynamic\\|e\\(?:lse\\|x\\(?:\\(?:ist\\|tend\\)s\\)\\)\\|f\\(?:inally\\|or\\|unction\\)\\|given\\|i\\(?:mport\\|nterface\\|[fns]\\)\\|let\\|module\\|n\\(?:ew\\|onempty\\)\\|o\\(?:bject\\|f\\|ut\\(?:er\\)?\\)\\|package\\|return\\|s\\(?:atisfies\\|uper\\|witch\\)\\|t\\(?:h\\(?:en\\|is\\|row\\)\\|ry\\)\\|v\\(?:alue\\|oid\\)\\|while\\)\\>" . font-lock-keyword-face))
  "Syntax highlighting for Ceylon keywords.")
;; (regexp-opt '("shared" "abstract" "formal" "default" "actual" "variable" "late" "native" "deprecated" "final" "sealed" "annotation" "suppressWarnings" "small" "static") t)
(defconst ceylon-font-lock-language-annos
  (list
   '("\\<\\(a\\(?:bstract\\|ctual\\|nnotation\\)\\|de\\(?:fault\\|precated\\)\\|f\\(?:\\(?:in\\|orm\\)al\\)\\|late\\|native\\|s\\(?:ealed\\|hared\\|mall\\|tatic\\|uppressWarnings\\)\\|variable\\)\\>" . font-lock-builtin-face))
  "Syntax highlighting for Ceylon language annotations.")
;; (regexp-opt '("doc" "by" "license" "see" "throws" "tagged") t)
(defconst ceylon-font-lock-doc-annos
  (list
   '("\\<\\(by\\|doc\\|license\\|see\\|t\\(?:agged\\|hrows\\)\\)\\>" . font-lock-builtin-face))
  "Syntax highlighting for Ceylon doc annotations.")
(defconst ceylon-font-lock-lidentifier
  (list
   '("\\<\\([[:lower:]_][[:alnum:]_]*\\)\\>" . font-lock-variable-name-face)
   '("\\<\\(\\\\i[[:alnum:]_]*\\)\\>" . font-lock-variable-name-face))
  "Syntax highlighting for Ceylon lowercase identifiers.")
(defconst ceylon-font-lock-uidentifier
  (list
   '("\\<\\([[:upper:]][[:alnum:]_]*\\)\\>" . font-lock-type-face)
   '("\\<\\(\\\\I[[:alnum:]_]*\\)\\>" . font-lock-type-face))
  "Syntax highlighting for Ceylon uppercase identifiers.")
(defconst ceylon-font-lock-all
  (append ceylon-font-lock-string ceylon-font-lock-keywords ceylon-font-lock-language-annos ceylon-font-lock-doc-annos ceylon-font-lock-lidentifier ceylon-font-lock-uidentifier)
  "Syntax highlighting for all Ceylon elements.")
(defvar ceylon-font-lock ceylon-font-lock-all ; e. g. set to ceylon-font-lock-keywords to only highlight keywords
  "Syntax highlighting for Ceylon; customizable (highlights all by default).")

(defvar ceylon-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; Comments. DO NOT LOOK UP HOW THIS WORKS, it's horrifying. (elisp.info node "Syntax Flags" if you're masochistic.)
    ;; It works, and we'll never have to touch it again. That's enough.
    ;; Note: this also recognizes '/!' and '#/' as line comments. That's how shitty this system is. Can't be fixed.
    ;; Doesn't matter, since '/!' and '#!' isn't legal Ceylon anyways.
    (modify-syntax-entry ?/ ". 124" st)
    (modify-syntax-entry ?* ". 23n" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?# ". 1" st)
    (modify-syntax-entry ?! ". 2" st)
    ;; Disable string highlighting so that the regexes in ceylon-font-lock-string can match
    (modify-syntax-entry ?\" "." st)
    st)
  "Syntax table for `ceylon-mode'.")

(set-default 'tab-width 4)
(defun ceylon-indent-line ()
  "Indent current line as Ceylon code."
  (beginning-of-line)
  (if (bobp) ; beginning of buffer?
      (indent-line-to 0)
    (let (cur-indent)
      (save-excursion
        (forward-line -1)
        (while (and (looking-at "^[ \t]*$") (not (bobp))) ; skip over blank lines
          (forward-line -1))
        (setq cur-indent (current-indentation))
        (let* ((start (line-beginning-position))
               (end   (line-end-position))
               (open-parens    (how-many "(" start end))
               (close-parens   (how-many ")" start end))
               (open-braces    (how-many "{" start end))
               (close-braces   (how-many "}" start end))
               (open-brackets  (how-many "\\[" start end))
               (close-brackets (how-many "\\]" start end))
               (balance (- (+ open-parens open-braces open-brackets)
                           (+ close-parens close-braces close-brackets))))
          (if (looking-at"[ \t]*\\(}\\|)\\|]\\)")
              (setq balance (+ balance 1)))
          (setq cur-indent (+ cur-indent (* balance tab-width)))))
      (if (looking-at "[ \t]*\\(}\\|)\\|]\\)")
          (setq cur-indent (- cur-indent tab-width)))
      (if (>= cur-indent 0)
          (indent-line-to cur-indent)))))
;; uncomment this to automatically reindent when a close-brace is typed;
;; however, this also sets the cursor *before* that brace, which is inconvenient,
;; so it's disabled for now.
;;(setq electric-indent-chars
;;  (append electric-indent-chars
;;          '(?})))

(defun ceylon-format-region ()
  "Format the current region with `ceylon format'.

The region must contain code that looks like a compilation unit
so that `ceylon.formatter' can parse it, usually one or more
complete declarations."
  (interactive)
  (setq
   ;; remember region before we start moving point
   region-beginning (region-beginning)
   region-end (region-end)
   ;; remember whether point was at beginning or end of region before formatting
   point-at-end (eq (point) (region-end)))
  ;; remember whether region had trailing newline before formatting
  (goto-char region-end)
  (setq newline-at-end (eq (point) (line-beginning-position)))
  ;; remember initial indentation of the code (`ceylon format --pipe` always uses initial indentation 0)
  (goto-char region-beginning)
  (setq initial-indentation (current-indentation))
  ;; pipe region through ceylon.formatter
  (shell-command-on-region region-beginning region-end "ceylon format --pipe" t t (get-buffer-create "*ceylon-format-errors*") t)
  ;; remember updated region
  (setq region-beginning (region-beginning)
        region-end (region-end)
        lines (count-lines region-beginning region-end))
  ;; `ceylon format --pipe` always uses initial indentation 0, indent all lines to remembered initial indentation
  (if (> initial-indentation 0)
      (dotimes (n lines)
        (beginning-of-line)
        (indent-to-column initial-indentation)
        (setq region-end (+ region-end initial-indentation))
        (forward-line 1)))
  ;; ceylon.formatter always adds trailing newline, remove if not present before
  (when (not newline-at-end)
    (delete-region (- region-end 1) region-end)
    (setq region-end (- region-end 1)))
  ;; move to region beginning or end, depending on which one was point before formatting
  (goto-char (if point-at-end region-end region-beginning)))

(define-key mode-specific-map "\C-f" 'ceylon-format-region)

(defun ceylon-mode ()
  "Major mode for editing Ceylon code."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ceylon-mode-syntax-table)
  (use-local-map ceylon-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(ceylon-font-lock))
  (set (make-local-variable 'indent-line-function) 'ceylon-indent-line)
  (setq major-mode 'ceylon-mode)
  (setq mode-name "Ceylon")
  (run-hooks 'ceylon-mode-hook))

(provide 'ceylon-mode)

;;; ceylon-mode.el ends here
