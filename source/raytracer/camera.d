module raytracer.camera;
/// Scene Camera.
class Camera {

    import raytracer.vector : Vector3;
    import raytracer.ray : Ray;

    private {
        immutable Vector3 _lowerLeft;
        immutable Vector3 _horizontal;
        immutable Vector3 _vertical;
        immutable Vector3 _origin;
    }

    /// Initialise with a camera position, subject vector, view up, field of view and aspect ratio.
    this(in Vector3 lookFrom, in Vector3 lookAt, in Vector3 viewUp, in float vfov, in float aspect) {
        import std.math : PI, tan;
        immutable theta = vfov*(PI / 180.0f);
        immutable halfHeight = (theta/2.0f).tan;
        immutable halfWidth = aspect * halfHeight;
        immutable w = Vector3.normalized(lookFrom - lookAt);
        immutable u = Vector3.normalized(Vector3.cross(viewUp, w));
        immutable v = Vector3.cross(w, u);
        this._origin = lookFrom;
        this._lowerLeft = this._origin - halfWidth*u -halfHeight*v - w;
        this._horizontal = 2*halfWidth*u;
        this._vertical = 2*halfHeight*v;
        
    }

    Ray getRay(float u, float v) const {
        return Ray(_origin, _lowerLeft +  u*_horizontal + v*_vertical - _origin);
    }
}