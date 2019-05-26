module raytracer.hitable;
import raytracer.vector : Vector3;
import raytracer.ray : Ray;

interface IHitable {
    HitRecord hit (in Ray r, float t_min, float t_max) pure const;
}

/// Struct for maintaining information on if an object has been hit with a ray and where.
struct HitRecord {
    float t;
    bool hit;
    Vector3 point;
    Vector3 normal;
}

/// Maintains a list of hitable objects.
class HitableList : IHitable {
    private {
        IHitable[] _list;
    }

    void add(IHitable obj) {
        //TODO: Construct KD Tree instead?
        _list ~= obj;
    }

    HitRecord hit(in Ray r, float t_min, float t_max) pure const {
        HitRecord rec;
        double closest = t_max;
        foreach(ref obj; _list) {
            auto temp_rec = obj.hit(r, t_min, closest);
            if(temp_rec.hit) {
                closest = temp_rec.t;
                rec = temp_rec;
            }
        }
        return rec;
    }
}