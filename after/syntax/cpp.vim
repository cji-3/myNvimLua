syntax cluster cCommentGroup add=DoxygenTag
syntax match DoxygenTag contained /\\\%(brief\|details\|version\|date\|copyright\|param\|tparam\|return\|returns\|retval\|since\|note\|warning\|deprecated\|see\|todo\|bug\|author\|file\)\>/
syntax match DoxygenTag contained /@\%(brief\|details\|version\|date\|copyright\|param\|tparam\|return\|returns\|retval\|since\|note\|warning\|deprecated\|see\|todo\|bug\|author\|file\)\>/
