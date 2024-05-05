;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "lolwierd"
      user-mail-address "lolwierd@outlook.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code Nerd Font" :size 16)
      doom-variable-pitch-font (font-spec :family "FreeSans" :size 16))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-challenger-deep)

;; start emacs maximized
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; (setq +doom-dashboard-menu-sections
;;       '(("Reload last session"
;;          :icon (nerd-icons-octicon "nf-oct-history" :face 'doom-dashboard-menu-title)
;;          :when (cond ((modulep! :ui workspaces)
;;                       (file-exists-p (expand-file-name persp-auto-save-fname persp-save-dir)))
;;                      ((require 'desktop nil t)
;;                       (file-exists-p (desktop-full-file-name))))
;;          :action doom/quickload-session)
;;         ("Open project"
;;          :icon (nerd-icons-octicon "nf-oct-briefcase" :face 'doom-dashboard-menu-title)
;;          :action projectile-switch-project)
;;         ("Jump to bookmark"
;;          :icon (nerd-icons-octicon "nf-oct-bookmark" :face 'doom-dashboard-menu-title)
;;          :action bookmark-jump)
;;         ("Open private configuration"
;;          :icon (nerd-icons-octicon "nf-oct-tools" :face 'doom-dashboard-menu-title)
;;          :when (file-directory-p doom-user-dir)
;;          :action doom/open-private-config)))
(setq +doom-dashboard-functions
      '(doom-dashboard-widget-banner
        ;; doom-dashboard-widget-shortmenu
        doom-dashboard-widget-loaded))
(defun +doom-dashboard-tweak ()
  (with-current-buffer (get-buffer +doom-dashboard-name)
    (setq-local mode-line-format nil
                mode-name ""
                evil-normal-state-cursor (list nil))))
(add-hook '+doom-dashboard-mode-hook #'+doom-dashboard-tweak)

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      scroll-margin 2                             ; It's nice to maintain a little margin
      display-time-default-load-average nil)      ; I don't think I've ever found this useful

(display-time-mode 1)                             ; Enable time in the mode-line
(global-subword-mode 1)                           ; Iterate through CamelCase words


;; Enter the new window on split and open an interactive buffer selection window
(setq evil-vsplit-window-right t
      evil-split-window-below t)
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

;; Do not create a new workspace on a new emacsclient window
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override
        `(+workspace-current-name)))

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
