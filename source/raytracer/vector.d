module raytracer.vector;
/// Vector template.
final struct Vector(ubyte size) 
if(size >= 2 && size <= 4)
{
    import std.traits : isFloatingPoint;
    import std.meta : allSatisfy;
    import std.math : sqrt;
    import std.algorithm : fold;
    import std.conv : to;
    import std.format : format;
    import std.range : iota;
    import std.algorithm : map;
    import std.array : array;
    import std.math : feqrel;

    private {
        static immutable _typeName = "Vector" ~ size.to!string;
        static immutable _props = ['x', 'y', 'z', 'w'];
        float[size] _components;
        static const _right = Vector3(1.0f, 0.0f, 0.0f);
        static const _back = Vector3(0.0f, 0.0f, -1.0f);
    }

    /// Construct a new vector with the given components
    this(T...)(T components) if (components.length == size && allSatisfy!(isFloatingPoint, T)) {
        _components = [components];
    }

    static foreach(i, c; _props[0..size]) {
        mixin("@property ref " ~ c ~ "() { return _components[" ~ i.stringof ~ "]; }");
        mixin("@property " ~ c ~ "() const { return _components[" ~ i.stringof ~ "]; }");
    }
    
    /// Magnitude of the Vector
    @property magnitude() const {
        return this.sqrMagnitude.sqrt;
    }

    /// Magnitude of the Vector
    alias length = magnitude;

    @property sqrMagnitude() const {
        return _components.fold!((a, b) => a + b^^2)(0.0f);
    }

    /// Helper to sum all components of a vector.
    private float sum() const {
        return _components.fold!((a, b) => a + b)(0.0f);
    }

    /// Access x, y, z and w at indices [0], [1], [2] and [3]
    float opIndex(in size_t index) const
    in { assert(index >= 0 && index < size, _typeName ~ " index out of bounds."); }
    do {
        return _components[index];
    }

    /// Set x, y, z and w at indices [0], [1], [2] and [3]
    float opIndexAssign(in float value, in size_t index)
    in { assert(index >= 0 && index < size, _typeName ~ " index out of bounds."); }
    do {
        return _components[index] = value;
    }

    /// Unary operations on Vector such as -- and ++, ~ and * are not supported.
    Vector opUnary(string op)() {
        static assert(op != "*" && op != "~", "Operand " ~ op ~ " not supported on " ~ _typeName);
        static foreach(i; 0 .. size) {{
            enum component = "_components[" ~ i.stringof ~ "]";
            mixin(component ~ " = " ~ op ~ component ~ ";");
        }}
        return this;
    }

    /// Vector on Vector operations such as addition and subtraction, yields a new Vector instance.
    Vector opBinary(string op)(in auto ref Vector rhs) const {
        static immutable args = size.iota.map!(i => "this[" ~ i.to!string ~ "] " ~ op ~ " rhs[" ~ i.to!string ~ "]").array;
        mixin("return Vector" ~ args.format!("(%-(%s%|, %));"));
    }

    /// Scalar on Vector operations such as addition and subtraction, yields a new Vector instance.
    Vector opBinary(string op)(in float scalar) const {
        static immutable args = size.iota.map!(i => "this[" ~ i.to!string ~ "] " ~ op ~ " scalar").array;
        mixin("return Vector" ~ args.format!("(%-(%s%|, %));"));
    }

    /// Scalar on Vector multiplication, yields a new Vector instance.
    Vector opBinaryRight(string op : "*")(in float scalar) const {
        static immutable args = size.iota.map!(i => "this[" ~ i.to!string ~ "] * scalar").array;
        mixin("return Vector" ~ args.format!("(%-(%s%|, %));"));
    }

    /// In-place Scalar on Vector operations such as addition and subtraction.
    Vector opOpAssign(string op)(in float scalar) {
        static foreach(i, c; _props[0..size]) {
            mixin("this." ~ c ~ " " ~ op ~ "= scalar;");
        }
        return this;
    }

    /// In-place Vector on Vector operations such as addition and subtraction.
    Vector opOpAssign(string op)(in auto ref Vector rhs) {
        static foreach(i; 0 .. size) {{
            enum component = "_components[" ~ i.stringof ~ "]";
            mixin(component ~ op ~ "= " ~ "rhs[" ~ i.to!string ~ "]" ~ ";");
        }}
        return this;
    }

    /// Test approximate equality between two Vector instances.
    bool opEquals(in Vector rhs) const {
        return (this - rhs).sqrMagnitude < float.epsilon;
    }

    /// Sets Vector components to scalar value.
    Vector opAssign(in float scalar) {
        static foreach(i, c; _props[0..size]) {
            mixin("this." ~ c ~ " = scalar;");
        }
        return this;
    }

    /// Compute the distance between two Vector instances.
    static float distance() (in auto ref Vector lhs, in auto ref Vector rhs) {
        return (lhs - rhs).magnitude;
    }

    /// Return a new normalized Vector.
    static Vector normalized() (in auto ref Vector v) {
        //FIXME: Simplify this.  We want to return a mutable zero vector.
        static immutable args = [0,0,0,0][0..size];
        mixin("auto zero = Vector" ~ args.format!("(%(%s.0f%|, %))") ~ ";");
        immutable mag = v.length();
        return mag > float.epsilon ? (v / mag) : zero;
    }

    /// Return a reference to a zero Vector (all components initialised to 0.0f)
    static ref const(Vector) zero() {
        static immutable args = [0,0,0,0][0..size];
        mixin("static const zero = Vector" ~ args.format!("(%(%s.0f%|, %))") ~ ";");
        return zero;
    }

    /// Return a reference to a unit Vector (all components initialised to 1.0f)
    static ref const(Vector) one() {
        static immutable args = [1,1,1,1][0..size];
        mixin("static const one = Vector" ~ args.format!("(%(%s.0f%|, %))") ~ ";");
        return one;
    }

    /// Return a reference to a Vector with components (0.0f, 0.0f, -1.0f)
    static ref const(Vector3) back() () if(size == 3) { return _back; }

    /// Return a reference to a Vector with components (1.0f, 0.0f, 0.0f)
    static ref const(Vector3) right() () if(size == 3) { return _right; }

    /// Linearly interpolate two vectors, returns a new Vector instance.
    static Vector lerp() (in auto ref Vector lhs, in auto ref Vector rhs, float t) {
        return (1.0f - t) * lhs + t * rhs;
    }

    /// Return the scalar dot product of two Vector instances.
    static float dot() (in auto ref Vector lhs, in auto ref Vector rhs) {
        return (lhs * rhs).sum;
    }

    /// Return the cross product of two Vector3 instances, returns a new Vector3 instance.
    static Vector3 cross() (in auto ref Vector3 lhs, in auto ref Vector3 rhs) if(size == 3) {
        return Vector3(lhs[1] * rhs[2] - lhs[2] * rhs[1],
                     -(lhs[0] * rhs[2] - lhs[2] * rhs[0]),
                       lhs[0] * rhs[1] - lhs[1] * rhs[0]);
    }

    string toString() const {
        return _components.format!("(%(%s, %))");
    }
}

/// 2D Vector with components x and y.
alias Vector2 = Vector!2;
/// 3D Vector with components x, y and z.
alias Vector3 = Vector!3;
/// 4D Vector with components x, y, z and w.
alias Vector4 = Vector!4;


// Barrage of simple unit tests.
unittest {
    import std.stdio : writeln;
    import std.math : feqrel;
    Vector2 vec2 = Vector2(1.0f, 2.0f);
    Vector3 vec3 = Vector3(1.0f, 2.0f, 3.0f);
    Vector4 vec4 = Vector4(1.0f, 2.0f, 3.0f, 4.0f);
    assert(vec2.x == 1.0f);
    assert(vec3.z == 3.0f);
    assert(vec4.w == 4.0f);
    assert(vec4.length.feqrel(5.47723f));
    auto t = Vector3(0.0f, 0.0f, 0.0f);
    t.x += 2;
    assert(t.x == 2.0f);
    auto z = t + Vector3(0.0f, 2.0f, 4.0f);
    assert(z.y == 2.0f);
    auto vecA = Vector3(7.0f, 4.0f, 3.0f);
    auto vecB = Vector3(17.0f, 6.0f, 2.0f);
    assert(Vector3.distance(vecA, vecB).feqrel(10.2469));
    assert(Vector3.distance(vecB, vecA).feqrel(10.2469));
    vecA *= 2.0f;
    assert(vecA == Vector3(14.0f, 8.0f, 6.0f));
    assert(Vector2(0.04, 0.931234) == Vector2(0.04, 0.93125));
    Vector3 v1 = Vector3(1.0f, 2.0f,  3.0f);
    Vector3 v2 = Vector3(2.0f, 3.0f, 4.0f);
    assert(Vector3.dot(Vector3.one(), Vector3.one()) == 3.0f);
    assert(Vector3.dot(v1, v2).feqrel(20.0f));
    assert(Vector3.cross(Vector3(3.0f, -3.0f, 1.0f), Vector3(-12.0f, 12.0f, -4.0f)) == Vector3.zero());
    assert(Vector3.cross(Vector3(3.0f, 2.0f, 1.0f), Vector3(-4.0f, 7.0f, 1.0f)) == Vector3(-5.0f, -7.0f, 29.0f));
    assert(Vector3.normalized(Vector3(1.0f, 2.0f, 3.0f)).magnitude().feqrel(1.0f));
    assert(Vector3.normalized(Vector3(0.0f, 0.0f, 0.0f)) == Vector3.zero());
    assert(Vector3.lerp(Vector3(0.2f, 0.2f, 0.2f), Vector3(0.5f, 0.7f, 1.0f), 1.0f) == Vector3(0.5f, 0.7f, 1.0f));
    assert(&Vector3.zero() == &Vector3.zero());
    assert(&Vector3.one() == &Vector3.one());
    assert(&Vector3.back() == &Vector3.back());
    assert(&Vector3.right() == &Vector3.right());
}