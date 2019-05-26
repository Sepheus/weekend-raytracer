module raytracer.hitable;
import raytracer.vector : Vector3;
import raytracer.ray : Ray;

interface IHitable {
    bool hit (in Ray r, float t_min, float t_max, out HitRecord rec) const;
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