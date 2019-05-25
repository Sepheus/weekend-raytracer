module hitable;
import vector;

interface IHitable {
    bool hit (in Ray r, float t_min, float t_max, out HitRecord rec) const;
}

/// Stores Ray data
struct Ray {
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

struct HitRecord {
    float t;
    bool hit = false;
    Vector3 point;
    Vector3 normal;
}

class HitableList : IHitable {
    private {
        IHitable[] _list;
    }

    void add(IHitable obj) {
        _list ~= obj;
    }

    bool hit(in Ray r, float t_min, float t_max, out HitRecord rec) const {
        HitRecord temp_rec;
        double closest = t_max;
        bool hit_anything;
        foreach(ref obj; _list) {
            if(obj.hit(r, t_min, closest, temp_rec)) {
                hit_anything = true;
                closest = temp_rec.t;
                rec = temp_rec;
            }
        }
        return hit_anything;
    }
}