;; reference: http://www.emacswiki.org/emacs/ModeTutorial

(defvar ceylon-mode-hook nil)

(defvar ceylon-mode-map
  (let ((map (make-keymap)))
;;   (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for Ceylon major mode")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ceylon\\'" . ceylon-mode))

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
  "Syntax highlighting for Ceylon keywords")
;; (regexp-opt '("shared" "abstract" "formal" "default" "actual" "variable" "late" "native" "deprecated" "final" "sealed" "annotation" "suppressWarnings" "small") t)
(defconst ceylon-font-lock-language-annos
  (list
   '("\\<\\(a\\(?:bstract\\|ctual\\|nnotation\\)\\|de\\(?:fault\\|precated\\)\\|f\\(?:\\(?:in\\|orm\\)al\\)\\|late\\|native\\|s\\(?:ealed\\|hared\\|mall\\|uppressWarnings\\)\\|variable\\)\\>" . font-lock-builtin-face))
  "Syntax highlighting for Ceylon language annotations")
;; (regexp-opt '("doc" "by" "license" "see" "throws" "tagged") t)
(defconst ceylon-font-lock-doc-annos
  (list
   '("\\<\\(by\\|doc\\|license\\|see\\|t\\(?:agged\\|hrows\\)\\)\\>" . font-lock-builtin-face))
  "Syntax highlighting for Ceylon doc annotations")
(defconst ceylon-font-lock-lidentifier
  (list
   '("\\<\\([[:lower:]][[:alnum:]]*\\)\\>" . font-lock-variable-name-face)
   '("\\<\\(\\\\i[[:alnum:]]*\\)\\>" . font-lock-variable-name-face))
  "Syntax highlighting for Ceylon lowercase identifiers")
(defconst ceylon-font-lock-uidentifier
  (list
   '("\\<\\([[:upper:]][[:alnum:]]*\\)\\>" . font-lock-type-face)
   '("\\<\\(\\\\I[[:alnum:]]*\\)\\>" . font-lock-type-face))
  "Syntax highlighting for Ceylon uppercase identifiers")
(defconst ceylon-font-lock-all
  (concatenate 'list ceylon-font-lock-keywords ceylon-font-lock-language-annos ceylon-font-lock-doc-annos ceylon-font-lock-lidentifier ceylon-font-lock-uidentifier)
  "Syntax highlighting for all Ceylon elements")
(defvar ceylon-font-lock ceylon-font-lock-all ; e. g. set to ceylon-font-lock-keywords to only highlight keywords
  "Syntax highlighting for Ceylon; customizable (highlights all by default)")

(defvar ceylon-mode-syntax-table
  (let ((st (make-syntax-table)))
    st)
  "Syntax table for ceylon-mode")

(defun ceylon-mode ()
  "Major mode for editing Ceylon"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ceylon-mode-syntax-table)
  (use-local-map ceylon-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(ceylon-font-lock))
  ;; TODO set indent function
  (setq major-mode 'ceylon-mode)
  (setq mode-name "Ceylon")
  (run-hooks 'ceylon-mode-hook))
(provide 'ceylon-mode)
