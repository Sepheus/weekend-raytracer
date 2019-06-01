module raytracer.materials.material;
import raytracer.ray : Ray;
import raytracer.vector : Vector3;
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
}