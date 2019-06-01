module raytracer.materials.metal;
import raytracer.materials.material;


/// Metallic material implementation.
class Metal : Material {

    private {
        immutable float _fuzz;
    }
    /// Initialise the Metal material with an albedo Vector3 and optional fuzz value.
    this(in Vector3 albedo, float fuzz = 0.0f) { 
        super(albedo); 
        this._fuzz = fuzz < 1.0f ? fuzz : 1.0f; 
    }

    /// Scatter the rays to create a metalic material.
    override MaterialRay scatter(in ref Ray inputRay, in ref HitRecord rec) const {
        immutable reflected = Vector3.reflect(Vector3.normalized(inputRay.direction), rec.normal);
        immutable scattered = Ray(rec.point, reflected + this._fuzz * this.diffuse());
        return MaterialRay(scattered, this._albedo, Vector3.dot(scattered.direction, rec.normal) > 0.0f);
    }
}