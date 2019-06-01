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
    render()
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

/// Render the scene.
Image render() {
    import std.parallelism : parallel;
    import std.random : uniform01;
    import std.math : sqrt;
    Image output = Image(1600, 800);
    immutable samples = 100.0f;
    HitableList world = new HitableList();
    const camera = new Camera();
    world.add(new Sphere(Vector3(0.0f, 0.0f, -1.0f), 0.5f, new Lambertian(Vector3(0.8f, 0.3f, 0.3f))));
    world.add(new Sphere(Vector3(0.0f, -100.5f, -1.0f), 100.0f, new Lambertian(Vector3(0.8f, 0.8f, 0.0f))));
    world.add(new Sphere(Vector3(1.0f, 0.0f, -1.0f), 0.5f, new Metal(Vector3(0.8f, 0.6f, 0.2f), 1.0f)));
    world.add(new Sphere(Vector3(-1.0f, 0.0f, -1.0f), 0.5f, new Metal(Vector3(0.8f, 0.8f, 0.8f), 0.3f)));
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