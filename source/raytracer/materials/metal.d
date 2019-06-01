module raytracer.materials.metal;
import raytracer.materials.material;


/// Diffuse material implementation.
class Metal : IMaterial {

    import raytracer.ray : Ray;
    import raytracer.vector : Vector3;
    import raytracer.hitable : HitRecord;

    private {
        immutable Vector3 _albedo;
    }
    /// Initialise the Lambertian material with an albedo Vector3.
    this(in Vector3 albedo) { this._albedo = albedo; }

    /// Scatter the rays to create a matte material.
    Material scatter(in ref Ray inputRay, in ref HitRecord rec) const {
        immutable reflected = Vector3.reflect(Vector3.normalized(inputRay.direction), rec.normal);
        immutable scattered = Ray(rec.point, reflected);
        return Material(scattered, this._albedo, Vector3.dot(scattered.direction, rec.normal) > 0.0f);
    }
}