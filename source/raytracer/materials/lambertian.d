module raytracer.materials.lambertian;
import raytracer.materials.material;


/// Diffuse material implementation.
class Lambertian : IMaterial {

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
        immutable target = rec.point + rec.normal + this.diffuse();
        immutable scattered = Ray(rec.point, target-rec.point);
        return Material(scattered, this._albedo, true);
    }

    /// Simulate matte material diffraction.
    private Vector3 diffuse(in Vector3 p = Vector3.one()) const {
        import std.random : uniform01;
        return p.sqrMagnitude < 1.0f ? p : diffuse(2.0f * Vector3(uniform01(), uniform01(), uniform01()) - Vector3.one());
    }
}