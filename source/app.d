import std.stdio;
import raytracer.raytracer;

/// Stores image width, height, depth and raw pixels.
struct Image {
    /// Image width in pixels.
    int width;
    /// Image height in pixels.
    int height;
    /// Image depth in bytes per pixel.
    int depth = 3;
    /// Raw pixel data in floats.
    float[][] pixels;
    /// Initialise image with weight and height.
    this(int width, int height) {
        this.width = width;
        this.height = height;
        this.pixels = new float[][](this.width * this.height, this.depth);
    }
}

// If piping from console, make sure console is UTF-8.
void main() {
    randomScene()
        .render()
        .ppm();
}

/// Linear blend to arrive at the correct colour for the position along the ray.
Vector3 colour() (in auto ref Ray r, in HitableList world, int depth = 0) {
    immutable rec = world.hit(r, 0.001, float.max);
    static immutable c = Vector3(0.5f, 0.7f, 1.0f);
    if(rec.hit) {
        immutable mat = rec.material.scatter(r, rec);
        if(depth < 50 && mat.scattered) {
            return mat.attenuation * mat.ray.colour(world, depth + 1);
        }
        else { return Vector3.zero(); }
    }
    immutable unit_direction = Vector3.normalized(r.direction());
    immutable t = (unit_direction.y + 1.0f)*0.5f;
    return Vector3.lerp(Vector3.one(), c, t);
}

/// Add objects to the scene.
HitableList scene() {
    HitableList world = new HitableList();
    world.add(new Sphere(Vector3(0.0f, 0.0f, -1.0f), 0.5f, new Lambertian(Vector3(0.1f, 0.2f, 0.5f))));
    world.add(new Sphere(Vector3(0.0f, -100.5f, -1.0f), 100.0f, new Lambertian(Vector3(0.8f, 0.8f, 0.0f))));
    world.add(new Sphere(Vector3(1.0f, 0.0f, -1.0f), 0.5f, new Metal(Vector3(0.8f, 0.6f, 0.2f), 0.25f)));
    world.add(new Sphere(Vector3(-1.0f, 0.0f, -1.0f), 0.5f, new Dielectric(1.5f)));
    world.add(new Sphere(Vector3(-1.0f, 0.0f, -1.0f), -0.45f, new Dielectric(1.5f)));
    return world;
}

/// Generate the scene on the book cover.
HitableList randomScene() {
    import std.random : uniform01;
    HitableList world = new HitableList();
    world.add(new Sphere(Vector3(0.0f, -1000.0f, 0.0f), 1000.0f, new Lambertian(Vector3(0.5f, 0.5f, 0.5f))));
    foreach(a; -11..11) {
        foreach(b; -11..11) {
            immutable material = uniform01();
            immutable centre = Vector3(a+0.9f*uniform01(), 0.2f, b+0.9f*uniform01());
            if((centre - Vector3(4.0f, 0.2f, 0.0f)).length() > 0.9) {
                immutable rnd = 0.5f * (Vector4(uniform01, uniform01, uniform01, uniform01) + 1.0f);
                immutable albedo = Vector3(uniform01, uniform01, uniform01) * Vector3(uniform01, uniform01, uniform01);
                auto mat =
                material < 0.8f  ? new Lambertian(albedo)                           :
                material < 0.95f ? new Metal(Vector3(rnd.x, rnd.y, rnd.z), rnd.w)   :
                                   new Dielectric(1.5f);
                world.add(new Sphere(centre, 0.2f, mat));
            }
        }
    }
    world.add(new Sphere(Vector3.up(), 1.0f, new Dielectric(1.5f)));
    world.add(new Sphere(Vector3(-4.0f, 1.0f, 0.0f), 1.0f, new Lambertian(Vector3(0.4, 0.2f, 0.1f))));
    world.add(new Sphere(Vector3(4.0f, 1.0f, 0.0f), 1.0f, new Metal(Vector3(0.7f, 0.6f, 0.5f))));
    return world;
}

/// Render the scene.
Image render(in HitableList world) {
    import std.parallelism : parallel;
    import std.random : uniform01;
    import std.math : sqrt;
    Image output = Image(1600, 800);
    immutable samples = 10.0f;  //Increase for higher fidelity.
    const camera = new Camera(Vector3(13.0f, 2.0f, 3.0f), Vector3.zero(), Vector3.up(), 20.0f, output.width / output.height);
    foreach(i, ref pixel; output.pixels.parallel) {
        auto col = Vector3(0.0f, 0.0f, 0.0f);
        immutable x = (i % output.width);
        immutable y = ((output.height - 1.0f) - (i / output.width));
        foreach(_; 0 .. samples) {
            immutable u = (x + uniform01()) / output.width;
            immutable v = (y + uniform01()) / output.height;
            col += camera
                        .getRay(u, v)
                        .colour(world);
        }
        col /= samples;
        pixel = [col.x.sqrt, col.y.sqrt, col.z.sqrt];
    }
    return output;
}

/// Output image data in ppm format.
void ppm() (in auto ref Image image) {
    import std.format : format;
    import std.algorithm : map;
    immutable header = "%s\n%s %s\n255";
    immutable pix = "%(%0.f %)";
    header
        .format("P3",image.width, image.height)
        .writeln;
    foreach(i, ref pixel; image.pixels) {
        pix
            .format(pixel.map!(n => n * 255))
            .writeln;
    }
}