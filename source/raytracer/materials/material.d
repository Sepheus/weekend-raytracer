module raytracer.materials.material;
import raytracer.ray : Ray;
import raytracer.vector : Vector3, Vector4;
import raytracer.hitable : HitRecord;

/// Material properties.
struct MaterialRay {
    /// The scattered ray.
    Ray ray;
    /// Albedo property.
    Vector3 attenuation;
    /// Whether the ray was scattered or not.
    bool scattered;
}

/// Abstract class for defining new material behaviour.
abstract class Material {
    protected import raytracer.ray : Ray;
    protected import raytracer.vector : Vector3;
    protected import raytracer.hitable : HitRecord;

    protected {
        immutable Vector3 _albedo;
    }

    /// Default constructor.
    this(in Vector3 albedo) { this._albedo = albedo; }

    /// Compute and return the result of scattering the ray across the material.
    abstract MaterialRay scatter(in ref Ray, in ref HitRecord) const;

    /// Simulate matte material diffraction.
    protected Vector3 diffuse(in Vector3 p = Vector3.one()) const {
        import std.random : uniform01;
        return p.sqrMagnitude < 1.0f ? p : diffuse(2.0f * Vector3(uniform01(), uniform01(), uniform01()) - Vector3.one());
    }

    /// Compute the refraction of a ray.
    protected Vector4 refract(in Vector3 v, in Vector3 n, float refIdx) const {
        import std.math : sqrt;
        immutable uv = Vector3.normalized(v);
        immutable dot = Vector3.dot(uv, n);
        immutable discriminant = 1.0f - (refIdx^^2) * (1.0f - dot^^2);
        immutable result = (refIdx *  (uv - n*dot) - n*discriminant.sqrt);
        return discriminant > 0.0f ? Vector4(result.x, result.y, result.z, 1.0f) : Vector4.zero();
    }

    /// Christophe Schlick's reflective algorithm for glass.
    protected float schlick(immutable float cosine, immutable float refIdx) const {
        immutable r0 = ((1.0f - refIdx) / (1.0f + refIdx))^^2;
        return r0 + (1.0f - r0) * (1.0f - cosine)^^5;
    }

}