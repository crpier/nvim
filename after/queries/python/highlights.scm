;; extends

((comment) @comment.todo @nospell
  (#lua-match? @comment.todo "^#%s*TODO:?")
  (#set! priority 105))
