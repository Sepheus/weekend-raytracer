module raytracer.ray;

/// Stores Ray data
struct Ray {
    import raytracer.vector : Vector3;
    private {
        const Vector3 a;
        const Vector3 b;
    }
    /// Initialise with origin and direction vectors.
    this(in Vector3 lhs, in Vector3 rhs) { a = lhs; b = rhs; }
    /// Return the origin vector of the ray.
    auto origin() const { return a; }
    /// Return the direction vector of the ray.
    auto direction() const { return b; }
    auto point_at_parameter(float t) const { return a + t*b; } 
}