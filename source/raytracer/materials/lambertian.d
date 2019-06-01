module raytracer.materials.lambertian;
import raytracer.materials.material;


/// Diffuse material implementation.
class Lambertian : Material {

    import raytracer.ray : Ray;
    import raytracer.vector : Vector3;
    import raytracer.hitable : HitRecord;

    /// Initialise Lambertian material with a Vector3 albedo value.
    this(in Vector3 albedo) { super(albedo); }

    /// Scatter the rays to create a matte material.
    override MaterialRay scatter(in ref Ray inputRay, in ref HitRecord rec) const {
        immutable target = rec.point + rec.normal + this.diffuse();
        immutable scattered = Ray(rec.point, target-rec.point);
        return MaterialRay(scattered, this._albedo, true);
    }

}