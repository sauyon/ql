/**
 * Generates java stubs for use in test code.
 *
 * Extend the abstract class `GeneratedDeclaration` with the declarations that should be generated.
 * This will generate stubs for all the required dependencies as well.
 */

import java

/** A type that should be in the generated code. */
abstract /*private*/ class GeneratedType extends RefType {
  GeneratedType() {
    (
      this instanceof Interface
      or
      this instanceof Class
    ) and
    not this instanceof AnonymousClass and
    not this instanceof LocalClass and
    not this.getPackage() instanceof ExcludedPackage
  }

  private string stubKeyword() {
    this instanceof Interface and result = "interface"
    or
    this instanceof Class and result = "class"
    // or
    // this instanceof Enum and result = "enum"
  }

  private string stubAbstractModifier() {
    if this.(Class).isAbstract() then result = "abstract " else result = ""
  }

  private string stubStaticModifier() {
    if this.isStatic() then result = "static " else result = ""
  }

  private string stubAccessibilityModifier() {
    if this.isPublic() then result = "public " else result = ""
  }

  /** Gets the entire Java stub code for this type. */
  final string getStub() {
    result =
      this.stubAbstractModifier() + this.stubStaticModifier() + this.stubAccessibilityModifier() +
        this.stubKeyword() + " " + this.getName() + stubGenericArguments(this) +
        stubBaseTypesString() + "\n{\n" + stubMembers() + "}"
  }

  private RefType getAnInterestingBaseType() {
    result = this.getASupertype() and
    not result instanceof TypeObject and
    result.getSourceDeclaration() != this
  }

  private string stubBaseTypesString() {
    if exists(getAnInterestingBaseType())
    then
      exists(string cls, string interface, string int_kw | result = cls + int_kw + interface |
        (
          if exists(getAnInterestingBaseType().(Class))
          then cls = " extends " + stubTypeName(getAnInterestingBaseType())
          else cls = ""
        ) and
        (
          if exists(getAnInterestingBaseType().(Interface))
          then (
            (if this instanceof Class then int_kw = " implements " else int_kw = " extends ") and
            interface = concat(stubTypeName(getAnInterestingBaseType().(Interface)), ", ")
          ) else (
            int_kw = "" and interface = ""
          )
        )
      )
    else result = ""
  }

  language[monotonicAggregates]
  private string stubMembers() {
    result = concat(Member m | m = this.getAGeneratedMember() | stubMember(m))
  }

  private Member getAGeneratedMember() {
    (
      result.getDeclaringType() = this
      or
      exists(NestedType nt | result = nt |
        nt = nt.getSourceDeclaration() and
        nt.getEnclosingType().getSourceDeclaration() = this
      )
    ) and
    not result.isPrivate() and
    not result instanceof StaticInitializer and
    not result instanceof InstanceInitializer
  }

  final Type getAGeneratedType() {
    result = getAnInterestingBaseType()
    or
    result = getAGeneratedMember().(Callable).getReturnType()
    or
    result = getAGeneratedMember().(Callable).getAParameter().getType()
    or
    result = getAGeneratedMember().(Field).getType()
    or
    result = getAGeneratedMember().(NestedType)
  }
}

/**
 * A declaration that should be generated.
 * This is extended in client code to identify the actual
 * declarations that should be generated.
 */
abstract class GeneratedDeclaration extends Element { }

private class IndirectType extends GeneratedType {
  IndirectType() {
    this.getASubtype() instanceof GeneratedType
    or
    this.(GenericType).getAParameterizedType() instanceof GeneratedType
    or
    exists(GeneratedType t |
      this = getAContainedType(t.getAGeneratedType()).(RefType).getSourceDeclaration()
    )
    or
    exists(GeneratedDeclaration decl |
      decl.(Member).getDeclaringType().getSourceDeclaration() = this
    )
    or
    this.(NestedType).getEnclosingType() instanceof GeneratedType
    or
    exists(NestedType nt | nt instanceof GeneratedType and this = nt.getEnclosingType())
  }
}

private class RootGeneratedType extends GeneratedType {
  RootGeneratedType() { this = any(GeneratedDeclaration decl).(RefType).getSourceDeclaration() }
}

private Type getAContainedType(Type t) {
  result = t
  or
  result = getAContainedType(t.(ParameterizedType).getATypeArgument())
}

/**
 * Specify packages to exclude.
 * Do not generate any types from these packages.
 */
abstract class ExcludedPackage extends Package { }

/** Exclude types from the standard library. */
private class DefaultLibs extends ExcludedPackage {
  DefaultLibs() { this.getName().matches(["java.%", "javax.%", "jdk.%", "sun.%"]) }
}

private string stubAccessibility(Member m) {
  if m.getDeclaringType() instanceof Interface
  then result = ""
  else
    if m.isPublic()
    then result = "public "
    else
      if m.isProtected()
      then result = "protected "
      else
        if m.isPrivate()
        then result = "private "
        else
          if m.isPackageProtected()
          then result = ""
          else result = "unknown-accessibility"
}

private string stubModifiers(Member m) {
  result = stubAccessibility(m) + stubStaticOrFinal(m) + stubAbstract(m)
}

private string stubStaticOrFinal(Member m) {
  if m.(Modifiable).isStatic()
  then result = "static "
  else
    if m.(Modifiable).isFinal()
    then result = "final "
    else result = ""
}

private string stubAbstract(Member m) {
  if m.getDeclaringType() instanceof Interface
  then result = ""
  else
    if m.isAbstract()
    then result = "abstract "
    else result = ""
}

private string stubTypeName(Type t) {
  if t instanceof PrimitiveType
  then result = t.getName()
  else
    if t instanceof VoidType
    then result = "void"
    else
      if t instanceof TypeVariable
      then result = t.getName()
      else
        if t instanceof Array
        then result = stubTypeName(t.(Array).getElementType()) + "[]"
        else
          if t instanceof RefType
          then
            result =
              stubQualifier(t) + t.(RefType).getSourceDeclaration().getName() +
                stubGenericArguments(t)
          else result = "<error>"
}

private string stubQualifier(RefType t) {
  if t instanceof NestedType
  then result = stubTypeName(t.(NestedType).getEnclosingType()) + "."
  else result = ""
}

language[monotonicAggregates]
private string stubGenericArguments(RefType t) {
  if t instanceof GenericType
  then
    result =
      "<" +
        concat(int n |
          exists(t.(GenericType).getTypeParameter(n))
        |
          t.(GenericType).getTypeParameter(n).getName(), "," order by n
        ) + ">"
  else
    if t instanceof ParameterizedType
    then
      result =
        "<" +
          concat(int n |
            exists(t.(ParameterizedType).getTypeArgument(n))
          |
            stubTypeName(t.(ParameterizedType).getTypeArgument(n)), "," order by n
          ) + ">"
    else result = ""
}

private string stubGenericMethodParams(Method m) {
  if m instanceof GenericMethod
  then
    result =
      " <" +
        concat(int n, TypeVariable param |
          param = m.(GenericMethod).getTypeParameter(n)
        |
          param.getName(), "," order by n
        ) + "> "
  else result = ""
}

private string stubImplementation(Callable c) {
  if c.isAbstract() or c.getDeclaringType() instanceof Interface
  then result = ";"
  else
    if c instanceof Constructor or c.getReturnType() instanceof VoidType
    then result = "{}"
    else result = "{ return " + stubDefaultValue(c.getReturnType()) + "; }"
}

private string stubDefaultValue(Type t) {
  if t instanceof RefType
  then result = "null"
  else
    if t instanceof CharacterType
    then result = "'0'"
    else
      if t instanceof BooleanType
      then result = "false"
      else
        if t instanceof NumericType
        then result = "0"
        else result = "<error>"
}

private string stubParameters(Callable c) {
  result =
    concat(int i, Parameter param |
      param = c.getParameter(i)
    |
      stubParameter(param), ", " order by i
    )
}

private string stubParameter(Parameter p) {
  exists(Type t, string suff | result = stubTypeName(t) + suff + " " + p.getName() |
    if p.isVarargs()
    then (
      t = p.getType().(Array).getElementType() and
      suff = "..."
    ) else (
      t = p.getType() and suff = ""
    )
  )
}

private string stubMember(Member m) {
  exists(Method c | m = c |
    result =
      "    " + stubModifiers(c) + stubGenericMethodParams(c) + stubTypeName(c.getReturnType()) + " "
        + c.getName() + "(" + stubParameters(c) + ")" + stubImplementation(c) + "\n"
  )
  or
  exists(Constructor c | m = c |
    result =
      "    " + stubModifiers(m) + c.getName() + "(" + stubParameters(c) + ")" +
        stubImplementation(c) + "\n"
  )
  or
  exists(Field f, string impl | f = m |
    /* and not f instanceof EnumConstant */
    /*if f.isConst() then impl = " = throw null" else*/ impl = "" and
    result =
      "    " + stubModifiers(m) + stubTypeName(f.getType()) + " " + f.getName() + impl + ";\n"
  )
  or
  exists(NestedType nt | nt = m | result = indent(nt.(GeneratedType).getStub()))
}

bindingset[s]
private string indent(string s) { result = "    " + s.replaceAll("\n", "\n    ") + "\n" }

private TopLevelType getTopLevel(RefType t) {
  result = t or
  result = getTopLevel(t.(NestedType).getEnclosingType())
}

class GeneratedTopLevel extends TopLevelType {
  GeneratedTopLevel() {
    this = this.getSourceDeclaration() and
    this instanceof GeneratedType
  }

  RefType getAReferencedType() {
    exists(GeneratedType t | this = getTopLevel(t) | result = getTopLevel(t.getAGeneratedType()))
  }

  private string stubAnImport() {
    exists(RefType t, string pkg, string name |
      t = getAReferencedType().getSourceDeclaration() and
      (t instanceof Class or t instanceof Interface) and
      t.hasQualifiedName(pkg, name) and
      t != this and
      pkg != "java.lang"
    |
      result = "import " + pkg + "." + name + ";\n"
    )
  }

  private string stubImports() { result = concat(stubAnImport()) + "\n" }

  private string stubPackage() {
    if this.getPackage().getName() != ""
    then result = "package " + this.getPackage().getName() + ";\n\n"
    else result = ""
  }

  private string stubComment() {
    result =
      "// Generated automatically from " + this.getQualifiedName() + " for testing purposes\n\n"
  }

  string stubFile() {
    result = stubComment() + stubPackage() + stubImports() + this.(GeneratedType).getStub() + "\n"
  }
}
