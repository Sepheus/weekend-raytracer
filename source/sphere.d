module sphere;
import hitable;
import vector;

class Sphere : IHitable {
    import std.math : sqrt;
    private {
        const Vector3 _centre;
        float _radius;
    }

    this(in Vector3 centre, float radius) { 
        this._centre = centre;
        this._radius = radius;
    }

    bool hit(in Ray r, float t_min, float t_max, out HitRecord rec) const {
        const oc  = r.origin() - this._centre;
        bool ret;
        immutable a = Vector3.dot(r.direction(), r.direction());
        immutable b = Vector3.dot(oc, r.direction());
        immutable c = Vector3.dot(oc, oc) - this._radius^^2;
        immutable discriminant = b^^2 - a*c;

        auto intersect = (float temp) {
            if(temp < t_max && temp > t_min) {
                rec.t = temp;
                rec.point = r.point_at_parameter(rec.t);
                rec.normal = (rec.point - this._centre) / this._radius;
                return true;
            }
            return false;
        };

        if(discriminant > 0.0f) {
            immutable rt = discriminant.sqrt;
            ret = intersect((-b - rt) / a) ? true : intersect((-b + rt) / a);
        }

        rec.hit = ret;
        return ret;
    }
}