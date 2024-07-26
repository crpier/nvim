;extends

(assignment right: 
  (call function: (identifier) @foo (#eq? @foo "js") 
    arguments: (argument_list (string (string_content) @injection.content)
    (#set! injection.language "javascript")
    )
  )
)
