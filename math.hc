U0 SkipWhitespace(U8 **str) {
  while (**str == ' ' || **str == '\t' || **str == '\n' || **str == '\r') {
    (*str)++;
  }
}

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

F64 ParseExpression(U8 **str);

F64 ParseNumber(U8 **str) {
  SkipWhitespace(str);
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
  SkipWhitespace(str);

  if (**str == '+') {
    (*str)++;
    return ParseFactor(str);
  }

  if (**str == '-') {
    (*str)++;
    return -ParseFactor(str);
  }

  if (**str == '(') {
    (*str)++; // Пропускаем '('
    F64 val = ParseExpression(str);
    SkipWhitespace(str);
    if (**str == ')') {
      (*str)++; // Пропускаем ')'
    }
    return val;
  }

  return ParseNumber(str);
}

F64 ParseTerm(U8 **str) {
  F64 left = ParseFactor(str);

  while (TRUE) {
    SkipWhitespace(str);
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
    } else {
      break;
    }
  }

  return left;
}

F64 ParseExpression(U8 **str) {
  F64 left = ParseTerm(str);

  while (TRUE) {
    SkipWhitespace(str);
    if (**str == '+') {
      (*str)++;
      left += ParseTerm(str);
    } else if (**str == '-') {
      (*str)++;
      left -= ParseTerm(str);
    } else {
      break;
    }
  }

  return left;
}

U0 PrintResult(F64 val) {
  I64 int_val = val;
  if (val == int_val) {
    "%d\n", int_val;
  } else {
    "%f\n", val;
  }
}

I64 Main(I64 argc, U8 **argv) {
  U8 expr[2048];
  expr[0] = 0;

  if (argc < 2) {
    "Usage: math <expression>\n";
    "Example: math 2+2\n";
    return 1;
  }

  I64 i;
  for (i = 1; i < argc; i++) {
    if (i > 1) {
      StrCat(expr, " ");
    }
    StrCat(expr, argv[i]);
  }

  U8 *ptr = expr;
  F64 result = ParseExpression(&ptr);

  PrintResult(result);

  return 0;
}
