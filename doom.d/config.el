;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Enable native compilation for every .elc file.
(setq native-comp-deferred-compilation t)

;; Make Emacs transparent.
(defconst doom-frame-transparency 90)
(set-frame-parameter (selected-frame) 'alpha doom-frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,doom-frame-transparency))
(defun dwc-smart-transparent-frame ()
  (set-frame-parameter
    (selected-frame)
    'alpha (if (frame-parameter (selected-frame) 'fullscreen)
              100
             doom-frame-transparency)))

;; Set Mono path for Omnisharp.
(setenv "FrameworkPathOverride" "/lib/mono/4.5")

;; Set font.
(setq  doom-font (font-spec :family "Iosevka" :size 16)
       doom-variable-pitch-font (font-spec :family "Iosevka" :size 16))

;; Set theme.
(setq doom-theme 'doom-dracula)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Ivan Ermacoff"
      user-mail-address "jermacoff@gmail.com")

;; First try to indent the current line, and if the line
;; was already indented, then try 'completion-at-point'.
(setq tab-always-indent 'complete)

;; Setup Unity support.
(after! unity
  (add-hook 'after-init-hook #'unity-build-code-shim)
  (add-hook 'after-init-hook #'unity-setup))

;; Configure Treemacs.
(when window-system
  (after! treemacs
    :commands (treemacs-follow-mode
               treemacs-filewatch-mode
               treemacs-fringe-indicator-mode
               treemacs-load-theme)
    :bind (("<f7>" . treemacs)
           ("<f8>" . treemacs-select-window)
           :map
           treemacs-mode-map
           ([C-tab] . aorst/treemacs-expand-all-projects))
    :hook ((after-init . aorst/treemacs-after-init-setup)
           (treemacs-mode . aorst/after-treemacs-setup)
           (treemacs-switch-workspace . treemacs-set-fallback-workspace)
           (treemacs-mode . aorst/treemacs-setup-title))
    :custom
    (treemacs-width 34)
    (treemacs-is-never-other-window t)
    (treemacs-space-between-root-nodes nil)
    (treemacs-indentation 2)
    :config
    (use-package treemacs-magit)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode nil)
    (set-face-attribute 'treemacs-root-face nil
                        :foreground (face-attribute 'default :foreground)
                        :height 1.0
                        :weight 'normal)
    (defun aorst/treemacs-ignore (file _)
      (or (s-ends-with? ".elc" file)
          (s-ends-with? ".o" file)
          (s-ends-with? ".a" file)
          (string= file ".svn")))
    (add-to-list 'treemacs-ignored-file-predicates #'aorst/treemacs-ignore)
    (treemacs-create-theme "Atom"
      :config
      (progn
        (treemacs-create-icon
         :icon (format " %s\t"
                       (all-the-icons-octicon
                        "repo"
                        :v-adjust -0.1
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (root))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-down"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "file-directory"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (dir-open))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-right"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "file-directory"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (dir-closed))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-down"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "package"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-open))
        (treemacs-create-icon
         :icon (format "%s\t%s\t"
                       (all-the-icons-octicon
                        "chevron-right"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal))
                       (all-the-icons-octicon
                        "package"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-closed))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "tag"
                        :height 0.9
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (tag-leaf))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "flame"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (error))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "stop"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (warning))
        (treemacs-create-icon
         :icon (format "%s\t"
                       (all-the-icons-octicon
                        "info"
                        :height 0.75
                        :v-adjust 0.1
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (info))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "file-media"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("png" "jpg" "jpeg" "gif" "ico" "tif" "tiff" "svg" "bmp"
                      "psd" "ai" "eps" "indd" "mov" "avi" "mp4" "webm" "mkv"
                      "wav" "mp3" "ogg" "midi"))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "file-code"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("yml" "yaml" "sh" "zsh" "fish" "c" "h" "cpp" "cxx" "hpp"
                      "tpp" "cc" "hh" "hs" "lhs" "cabal" "py" "pyc" "rs" "el"
                      "elc" "clj" "cljs" "cljc" "ts" "tsx" "vue" "css" "html"
                      "htm" "dart" "java" "kt" "scala" "sbt" "go" "js" "jsx"
                      "hy" "json" "jl" "ex" "exs" "eex" "ml" "mli" "pp" "dockerfile"
                      "vagrantfile" "j2" "jinja2" "tex" "racket" "rkt" "rktl" "rktd"
                      "scrbl" "scribble" "plt" "makefile" "elm" "xml" "xsl" "rb"
                      "scss" "lua" "lisp" "scm" "sql" "toml" "nim" "pl" "pm" "perl"
                      "vimrc" "tridactylrc" "vimperatorrc" "ideavimrc" "vrapperrc"
                      "cask" "r" "re" "rei" "bashrc" "zshrc" "inputrc" "editorconfig"
                      "gitconfig"))
        (treemacs-create-icon
         :icon (format "  %s\t"
                       (all-the-icons-octicon
                        "book"
                        :v-adjust 0
                        :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("lrf" "lrx" "cbr" "cbz" "cb7" "cbt" "cba" "chm" "djvu"
                      "doc" "docx" "pdb" "pdb" "fb2" "xeb" "ceb" "inf" "azw"
                      "azw3" "kf8" "kfx" "lit" "prc" "mobi" "pkg" "opf" "txt"
                      "pdb" "ps" "rtf" "pdg" "xml" "tr2" "tr3" "oxps" "xps"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-text"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("md" "markdown" "rst" "log" "org" "txt"
                      "CONTRIBUTE" "LICENSE" "README" "CHANGELOG"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-binary"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("exe" "dll" "obj" "so" "o" "out"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-pdf"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("pdf"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-zip"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions ("zip" "7z" "tar" "gz" "rar" "tgz"))
        (treemacs-create-icon
         :icon (format "  %s\t" (all-the-icons-octicon
                                 "file-text"
                                 :v-adjust 0
                                 :face '(:inherit font-lock-doc-face :slant normal)))
         :extensions (fallback))))
    :init
    (defun aorst/treemacs-variable-pitch-labels (&rest _)
      (dolist (face '(treemacs-file-face
                      treemacs-root-face
                      treemacs-tags-face
                      treemacs-directory-face
                      treemacs-directory-collapsed-face
                      treemacs-term-node-face
                      treemacs-help-title-face
                      treemacs-help-column-face
                      treemacs-git-added-face
                      treemacs-git-ignored-face
                      treemacs-git-renamed-face
                      treemacs-git-conflict-face
                      treemacs-git-modified-face
                      treemacs-git-unmodified-face
                      treemacs-git-untracked-face
                      treemacs-root-unreadable-face
                      treemacs-root-remote-face
                      treemacs-root-remote-unreadable-face
                      treemacs-root-remote-disconnected-face
                      treemacs-fringe-indicator-face
                      treemacs-on-failure-pulse-face
                      treemacs-on-success-pulse-face))
        (let ((faces (face-attribute face :inherit nil)))
          (set-face-attribute
           face nil :inherit
           `(variable-pitch ,@(delq 'unspecified (if (listp faces) faces (list faces))))))))
    (defun aorst/treemacs-after-init-setup ()
      "Set treemacs theme, open treemacs, and expand all projects."
      (treemacs-load-theme "Atom")
      (setq treemacs-collapse-dirs 0)
      (treemacs)
      (windmove-right))
    (defun aorst/after-treemacs-setup ()
      "Set treemacs buffer common settings."
      (setq tab-width 1
            mode-line-format nil
            line-spacing 5)
      (setq-local scroll-step 1)
      (setq-local scroll-conservatively 10000)
      (set-window-fringes nil 0 0 t)
      (aorst/treemacs-variable-pitch-labels))
    (defun aorst/treemacs-setup-fringes ()
      "Set treemacs buffer fringes."
      (set-window-fringes nil 0 0 t)
      (aorst/treemacs-variable-pitch-labels))
    (advice-add #'treemacs-select-window :after #'aorst/treemacs-setup-fringes)
    (defun aorst/treemacs-setup-title ()
      (let ((bg (face-attribute 'default :background))
            (fg (face-attribute 'default :foreground)))
        (face-remap-add-relative 'header-line
                                 :background bg :foreground fg
                                 :box `(:line-width ,(/ (line-pixel-height) 2) :color ,bg)))
      (setq header-line-format
            '((:eval
               (let* ((text (treemacs-workspace->name (treemacs-current-workspace)))
                      (extra-align (+ (/ (length text) 2) 1))
                      (width (- (/ (window-width) 2) extra-align)))
                 (concat (make-string width ?\s) text))))))))

;; Configure tab lines.
(unless (or (version< emacs-version "27") (not window-system))
  (use-package! tab-line
    :ensure nil
    :hook (after-init . global-tab-line-mode)
    :config
    (defun tab-line-close-tab (&optional e)
      "Close the selected tab.

If tab is presented in another window, close the tab by using
`bury-buffer` function.  If tab is unique to all existing
windows, kill the buffer with `kill-buffer` function.  Lastly, if
no tabs left in the window, it is deleted with `delete-window`
function."
      (interactive "e")
      (let* ((posnp (event-start e))
             (window (posn-window posnp))
             (buffer (get-pos-property 1 'tab (car (posn-string posnp)))))
        (with-selected-window window
          (let ((tab-list (tab-line-tabs-window-buffers))
                (buffer-list (flatten-list
                              (seq-reduce (lambda (list window)
                                            (select-window window t)
                                            (cons (tab-line-tabs-window-buffers) list))
                                          (window-list) nil))))
            (select-window window)
            (if (> (seq-count (lambda (b) (eq b buffer)) buffer-list) 1)
                (progn
                  (if (eq buffer (current-buffer))
                      (bury-buffer)
                    (set-window-prev-buffers window (assq-delete-all buffer (window-prev-buffers)))
                    (set-window-next-buffers window (delq buffer (window-next-buffers))))
                  (unless (cdr tab-list)
                    (ignore-errors (delete-window window))))
              (and (kill-buffer buffer)
                   (unless (cdr tab-list)
                     (ignore-errors (delete-window window)))))))))

    (defcustom tab-line-tab-min-width 10
      "Minimum width of a tab in characters."
      :type 'integer
      :group 'tab-line)

    (defcustom tab-line-tab-max-width 30
      "Maximum width of a tab in characters."
      :type 'integer
      :group 'tab-line)

    (defun aorst/tab-line-name-buffer (buffer &rest _buffers)
      "Create name for tab with padding and truncation.

If buffer name is shorter than `tab-line-tab-max-width' it gets
centered with spaces, otherwise it is truncated, to preserve
equal width for all tabs.  This function also tries to fit as
many tabs in window as possible, so if there are no room for tabs
with maximum width, it calculates new width for each tab and
truncates text if needed.  Minimal width can be set with
`tab-line-tab-min-width' variable."
      (with-current-buffer buffer
        (let* ((window-width (window-width (get-buffer-window)))
               (tab-amount (length (tab-line-tabs-window-buffers)))
               (window-max-tab-width (if (>= (* (+ tab-line-tab-max-width 3) tab-amount) window-width)
                                         (/ window-width tab-amount)
                                       tab-line-tab-max-width))
               (tab-width (- (cond ((> window-max-tab-width tab-line-tab-max-width)
                                    tab-line-tab-max-width)
                                   ((< window-max-tab-width tab-line-tab-min-width)
                                    tab-line-tab-min-width)
                                   (t window-max-tab-width))
                             3)) ;; compensation for ' x ' button
               (buffer-name (string-trim (buffer-name)))
               (name-width (length buffer-name)))
          (if (>= name-width tab-width)
              (concat  " " (truncate-string-to-width buffer-name (- tab-width 2)) "…")
            (let* ((padding (make-string (+ (/ (- tab-width name-width) 2) 1) ?\s))
                   (buffer-name (concat padding buffer-name)))
              (concat buffer-name (make-string (- tab-width (length buffer-name)) ?\s)))))))

    (setq tab-line-close-button-show t
          tab-line-new-button-show nil
          tab-line-separator ""
          tab-line-tab-name-function #'aorst/tab-line-name-buffer
          tab-line-right-button (propertize (if (char-displayable-p ?▶) " ▶ " " > ")
                                            'keymap tab-line-right-map
                                            'mouse-face 'tab-line-highlight
                                            'help-echo "Click to scroll right")
          tab-line-left-button (propertize (if (char-displayable-p ?◀) " ◀ " " < ")
                                           'keymap tab-line-left-map
                                           'mouse-face 'tab-line-highlight
                                           'help-echo "Click to scroll left")
          tab-line-close-button (propertize (if (char-displayable-p ?×) " × " " x ")
                                            'keymap tab-line-tab-close-map
                                            'mouse-face 'tab-line-close-highlight
                                            'help-echo "Click to close tab"))

    (let ((bg (if (facep 'solaire-default-face)
                  (face-attribute 'solaire-default-face :background)
                (face-attribute 'default :background)))
          (fg (face-attribute 'default :foreground))
          (base (face-attribute 'mode-line :background))
          (box-width (/ (line-pixel-height) 2)))
      (set-face-attribute 'tab-line nil :background base :foreground fg :height 1.0 :inherit nil :box (list :line-width -1 :color base))
      (set-face-attribute 'tab-line-tab nil :foreground fg :background bg :weight 'normal :inherit nil :box (list :line-width box-width :color bg))
      (set-face-attribute 'tab-line-tab-inactive nil :foreground fg :background base :weight 'normal :inherit nil :box (list :line-width box-width :color base))
      (set-face-attribute 'tab-line-tab-current nil :foreground fg :background bg :weight 'normal :inherit nil :box (list :line-width box-width :color bg)))

    (dolist (mode '(ediff-mode
                    process-menu-mode
                    term-mode
                    vterm-mode))
      (add-to-list 'tab-line-exclude-modes mode))))

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
