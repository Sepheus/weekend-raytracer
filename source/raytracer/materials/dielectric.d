module raytracer.materials.dielectric;
import raytracer.materials.material;

/// Glass type material implementation.
class Dielectric : Material {

    private {
        immutable float _refIdx;
    }

    /// Initialise with refractive index.  Air = 1, Glass = 1.3-1.7, Diamond = 2.4
    this(in float refIdx) { 
        super(Vector3(1.0f, 1.0f, 1.0f)); 
        this._refIdx = refIdx;
    }


    /// Create the glass effect by reflecting or refracting based on the angle.
    override MaterialRay scatter(in ref Ray inputRay, in ref HitRecord rec) const {
        import std.typecons : Tuple;
        import std.random : uniform01;
        alias Result = Tuple!(immutable Vector3, "normal", immutable float, "refIdx", immutable float, "cosine");
        immutable reflected = Vector3.reflect(inputRay.direction, rec.normal);
        immutable dot = Vector3.dot(inputRay.direction, rec.normal);
        immutable res = dot > 0.0f 
                            ? Result(-rec.normal, this._refIdx, this._refIdx * dot / inputRay.direction.length()) 
                            : Result(rec.normal, 1.0f / this._refIdx, -dot / inputRay.direction.length());
        immutable refracted = this.refract(inputRay.direction, res.normal, res.refIdx);
        immutable reflectProb = refracted.w ? this.schlick(res.cosine, res.refIdx) : 1.0f;
        return uniform01() < reflectProb
                           ? MaterialRay(Ray(rec.point, reflected), this._albedo, true)
                           : MaterialRay(Ray(rec.point, Vector3(refracted.x, refracted.y, refracted.z)), this._albedo, true);
    }
}