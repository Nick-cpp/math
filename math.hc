U0 StrCat(U8 *dst, U8 *src) {
  while (*dst != 0) {
    dst++;
  }
  while (*src != 0) {
    *dst = *src;
    dst++;
    src++;
  }
  *dst = 0;
}

I64 StrCmp(U8 *s1, U8 *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return *s1 - *s2;
}

U0 StripSpaces(U8 *dst, U8 *src) {
  while (*src != 0) {
    if (*src != ' ' && *src != '\t' && *src != '\r' && *src != '\n') {
      *dst = *src;
      dst++;
    }
    src++;
  }
  *dst = 0;
}

F64 ParseExpression(U8 **str);

F64 ParseNumber(U8 **str) {
  F64 val = 0.0;
  F64 div = 1.0;
  Bool has_dot = FALSE;

  while ((**str >= '0' && **str <= '9') || **str == '.') {
    if (**str == '.') {
      has_dot = TRUE;
      (*str)++;
      continue;
    }
    if (!has_dot) {
      val = val * 10.0 + (**str - '0');
    } else {
      div *= 10.0;
      val = val + (**str - '0') / div;
    }
    (*str)++;
  }
  return val;
}

F64 ParseFactor(U8 **str) {
  if (**str == '+') {
    (*str)++;
    return ParseFactor(str);
  }

  if (**str == '-') {
    (*str)++;
    return -ParseFactor(str);
  }

  if (**str == '(') {
    (*str)++;
    F64 val = ParseExpression(str);
    if (**str == ')') {
      (*str)++;
    }
    return val;
  }

  return ParseNumber(str);
}

F64 ParseTerm(U8 **str) {
  F64 left = ParseFactor(str);

  while (**str == '*' || **str == '/') {
    if (**str == '*') {
      (*str)++;
      left *= ParseFactor(str);
    } else if (**str == '/') {
      (*str)++;
      F64 right = ParseFactor(str);
      if (right != 0.0) {
        left /= right;
      } else {
        "Error: Division by zero\n";
        return 0.0;
      }
    }
  }

  return left;
}

F64 ParseExpression(U8 **str) {
  F64 left = ParseTerm(str);

  while (**str == '+' || **str == '-') {
    if (**str == '+') {
      (*str)++;
      left += ParseTerm(str);
    } else if (**str == '-') {
      (*str)++;
      left -= ParseTerm(str);
    }
  }

  return left;
}

U0 PrintResult(F64 val) {
  "%.10f\n", val;
}

I64 Main(I64 argc, U8 **argv) {
  U8 raw_expr[2048];
  U8 clean_expr[2048];
  raw_expr[0] = 0;

  if (argc < 2) {
    "Usage: math 'expression'\n";
    return 1;
  }

  if (!StrCmp(argv[1], "--version")) {
    "math v1.4\n";
    return 0;
  }

  I64 i;
  for (i = 1; i < argc; i++) {
    StrCat(raw_expr, argv[i]);
  }

  StripSpaces(clean_expr, raw_expr);

  U8 *ptr = clean_expr;
  F64 result = ParseExpression(&ptr);

  PrintResult(result);

  return 0;
}
