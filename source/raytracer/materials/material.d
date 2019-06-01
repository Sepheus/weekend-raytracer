module raytracer.materials.material;
import raytracer.ray : Ray;
import raytracer.vector : Vector3;
import raytracer.hitable : HitRecord;

/// Material properties.
struct Material {
    /// The scattered ray.
    Ray ray;
    /// Albedo property.
    Vector3 attenuation;
    /// Whether the ray was scattered or not.
    bool scattered;
}

/// Public interface for defining new materials.
interface IMaterial {
    /// How the material should scatter.
    Material scatter(in ref Ray, in ref HitRecord) const;
}