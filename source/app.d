import std.stdio;
import vector;

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

/// Stores Ray data
struct Ray {
    private {
        const Vector3 a;
        const Vector3 b;
    }
    /// Initialise with origin and direction vectors.
    this(in ref Vector3 lhs, in ref Vector3 rhs) { a = lhs; b = rhs; }
    /// Return the origin vector of the ray.
    auto origin() const { return a; }
    /// Return the direction vector of the ray.
    auto direction() const { return b; }
    auto point_at_parameter(float t) const { return a + t*b; } 
}

// If piping from console, make sure console is UTF-8.
void main() {
    sky()
        .ppm();
}

/// Generate the 200x100 test gradient.
Image generate() {
    import std.typecons : scoped;
    Image output = Image(200, 100);
    int p = 0;
    foreach_reverse(j; 0.0f .. output.height) {
        foreach(i; 0.0f .. output.width) {
            auto col = scoped!Vector3(i / output.width, j / output.height, 0.2);
            output.pixels[p++] = [col.x, col.y, col.z];
        }
    }
    return output;
}

/// Linear blend to arrive at the correct colour for the position along the ray.
Vector3 colour() (in auto ref Ray r) {
    import std.typecons : scoped;
    if(r.hit_sphere(Vector3.back(), 0.5f)) { return Vector3.right(); }
    auto unit_direction = Vector3.normalized(r.direction());
    immutable t = (unit_direction.y + 1.0f)*0.5f;
    return Vector3.lerp(Vector3.one(), scoped!Vector3(0.5f, 0.7f, 1.0f), t);
}

/// Trace the sky background.
Image sky() {
    import std.typecons : scoped;
    Image output = Image(200, 100);
    int p = 0;
    const lowerLeft = new Vector3(-2.0f, -1.0f, -1.0f);
    const horizontal = new Vector3(4.0f, 0.0f, 0.0f);
    const vertical = new Vector3(0.0f, 2.0f, 0.0f);
    const origin = Vector3.zero();
        foreach_reverse(j; 0.0f .. output.height) {
        foreach(i; 0.0f .. output.width) {
            immutable u = i / output.width;
            immutable v = j / output.height;
            immutable calc = lowerLeft + u*horizontal + v*vertical;
            auto col = Ray(origin, calc).colour();
            output.pixels[p++] = [col.x, col.y, col.z];
        }
    }
    return output;
}

/// Check if the ray intersects with the sphere at any point, true if it does.
bool hit_sphere() (in auto ref Ray r, in auto ref Vector3 centre, float radius) {
    auto oc = r.origin() - centre;
    immutable a = Vector3.dot(r.direction(), r.direction());
    immutable b = 2.0 * Vector3.dot(oc, r.direction());
    immutable c = Vector3.dot(oc, oc) - radius^^2;
    immutable discriminant = b^^2 - 4*a*c;
    return (discriminant > 0.0f);
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