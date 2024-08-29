--region ffi
-- credits: Valve Corporation, lua.org, "none"

--
-- todo; add asserts
--       add handling for div by 0
--       change vector normalize
--       add Vector2 and Angle files / implementation
--

-- localize vars
local type         = type;
local setmetatable = setmetatable;
local tostring     = tostring;

local math_pi   = math.pi;
local math_min  = math.min;
local math_max  = math.max;
local math_deg  = math.deg;
local math_rad  = math.rad;
local math_sqrt = math.sqrt;
local math_sin  = math.sin;
local math_cos  = math.cos;
local math_atan = math.atan;
local math_acos = math.acos;
local math_fmod = math.fmod;

-- set up vector3 metatable
local _V3_MT   = {};
_V3_MT.__index = _V3_MT;

--
-- create Vector3 object
--
local function Vector3( x, y, z )
    -- check args
    if( type( x ) ~= "number" ) then
        x = 0.0;
    end

    if( type( y ) ~= "number" ) then
        y = 0.0;
    end

    if( type( z ) ~= "number" ) then
        z = 0.0;
    end

    x = x or 0.0;
    y = y or 0.0;
    z = z or 0.0;

    return setmetatable(
        {
            x = x,
            y = y,
            z = z
        },
        _V3_MT
    );
end

--
-- metatable operators
--
function _V3_MT.__eq( a, b ) -- equal to another vector
    return a.x == b.x and a.y == b.y and a.z == b.z;
end

function _V3_MT.__unm( a ) -- unary minus
    return Vector3(
        -a.x,
        -a.y,
        -a.z
    );
end

function _V3_MT.__add( a, b ) -- add another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x + b.x,
            a.y + b.y,
            a.z + b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x + b,
            a.y + b,
            a.z + b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a + b.x,
            a + b.y,
            a + b.z
        );
    end
end

function _V3_MT.__sub( a, b ) -- subtract another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x - b,
            a.y - b,
            a.z - b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a - b.x,
            a - b.y,
            a - b.z
        );
    end
end

function _V3_MT.__mul( a, b ) -- multiply by another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x * b.x,
            a.y * b.y,
            a.z * b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x * b,
            a.y * b,
            a.z * b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a * b.x,
            a * b.y,
            a * b.z
        );
    end
end

function _V3_MT.__div( a, b ) -- divide by another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x / b.x,
            a.y / b.y,
            a.z / b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x / b,
            a.y / b,
            a.z / b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a / b.x,
            a / b.y,
            a / b.z
        );
    end
end

function _V3_MT.__tostring( a ) -- used for 'tostring( vector3_object )'
    return "( " .. a.x .. ", " .. a.y .. ", " .. a.z .. " )";
end

--
-- metatable misc funcs
--
function _V3_MT:clear() -- zero all vector vars
    self.x = 0.0;
    self.y = 0.0;
    self.z = 0.0;
end

function _V3_MT:unpack() -- returns axes as 3 seperate arguments
    return self.x, self.y, self.z;
end

function _V3_MT:length_2d_sqr() -- squared 2D length
    return ( self.x * self.x ) + ( self.y * self.y );
end

function _V3_MT:length_sqr() -- squared 3D length
    return ( self.x * self.x ) + ( self.y * self.y ) + ( self.z * self.z );
end

function _V3_MT:length_2d() -- 2D length
    return math_sqrt( self:length_2d_sqr() );
end

function _V3_MT:length() -- 3D length
    return math_sqrt( self:length_sqr() );
end

function _V3_MT:dot( other ) -- dot product
    return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
end

function _V3_MT:cross( other ) -- cross product
    return Vector3(
        ( self.y * other.z ) - ( self.z * other.y ),
        ( self.z * other.x ) - ( self.x * other.z ),
        ( self.x * other.y ) - ( self.y * other.x )
    );
end

function _V3_MT:dist_to( other ) -- 3D length to another vector
    return ( other - self ):length();
end

function _V3_MT:is_zero( tolerance ) -- is the vector zero (within tolerance value, can pass no arg if desired)?
    tolerance = tolerance or 0.001;

    if( self.x < tolerance and self.x > -tolerance and
        self.y < tolerance and self.y > -tolerance and
        self.z < tolerance and self.z > -tolerance ) then
        return true;
    end

    return false;
end

function _V3_MT:normalize() -- normalizes this vector and returns the length
    local l = self:length();
    if( l <= 0.0 ) then
        return 0.0;
    end

    self.x = self.x / l;
    self.y = self.y / l;
    self.z = self.z / l;

    return l;
end

function _V3_MT:normalize_no_len() -- normalizes this vector (no length returned)
    local l = self:length();
    if( l <= 0.0 ) then
        return;
    end

    self.x = self.x / l;
    self.y = self.y / l;
    self.z = self.z / l;
end

function _V3_MT:normalized() -- returns a normalized unit vector
    local l = self:length();
    if( l <= 0.0 ) then
        return Vector3();
    end

    return Vector3(
        self.x / l,
        self.y / l,
        self.z / l
    );
end

--
-- other math funcs
--
local function clamp( cur_val, min_val, max_val ) -- clamp number within 'min_val' and 'max_val'
    if( cur_val < min_val ) then
        return min_val;

    elseif( cur_val > max_val ) then
        return max_val;
    end

    return cur_val;
end

local function normalize_angle( angle ) -- ensures angle axis is within [-180, 180]
    local out;
    local str;

    -- bad number
    str = tostring( angle );
    if( str == "nan" or str == "inf" ) then
        return 0.0;
    end

    -- nothing to do, angle is in bounds
    if( angle >= -180.0 and angle <= 180.0 ) then
        return angle;
    end

    -- bring into range
    out = math_fmod( math_fmod( angle + 360.0, 360.0 ), 360.0 );
    if( out > 180.0 ) then
        out = out - 360.0;
    end

    return out;
end

local function vector_to_angle( forward ) -- vector -> euler angle
    local l;
    local pitch;
    local yaw;

    l = forward:length();
    if( l > 0.0 ) then
        pitch = math_deg( math_atan( -forward.z, l ) );
        yaw   = math_deg( math_atan( forward.y, forward.x ) );
    else
        if( forward.x > 0.0 ) then
            pitch = 270.0;
        else
            pitch = 90.0;
        end

        yaw = 0.0;
    end

    return Vector3( pitch, yaw, 0.0 );
end

local function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );

    return Vector3(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end

local function angle_right( angle ) -- angle -> direction vector (right)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );
    local sin_roll  = math_sin( math_rad( angle.z ) );
    local cos_roll  = math_cos( math_rad( angle.z ) );

    return Vector3(
        -1.0 * sin_roll * sin_pitch * cos_yaw + -1.0 * cos_roll * -sin_yaw,
        -1.0 * sin_roll * sin_pitch * sin_yaw + -1.0 * cos_roll * cos_yaw,
        -1.0 * sin_roll * cos_pitch
    );
end

local function angle_up( angle ) -- angle -> direction vector (up)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );
    local sin_roll  = math_sin( math_rad( angle.z ) );
    local cos_roll  = math_cos( math_rad( angle.z ) );

    return Vector3(
        cos_roll * sin_pitch * cos_yaw + -sin_roll * -sin_yaw,
        cos_roll * sin_pitch * sin_yaw + -sin_roll * cos_yaw,
        cos_roll * cos_pitch
    );
end

local function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;

    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math_acos( fwd:dot( delta ) / delta:length() );

    return math_max( 0.0, math_deg( fov ) );
end
local ffi = require("ffi")

local line_goes_through_smoke

do
	local success, match = client.find_signature("client_panorama.dll", "\x55\x8B\xEC\x83\xEC\x08\x8B\x15\xCC\xCC\xCC\xCC\x0F\x57")

	if success and match ~= nil then
		local lgts_type = ffi.typeof("bool(__thiscall*)(float, float, float, float, float, float, short);")

		line_goes_through_smoke = ffi.cast(lgts_type, match)
	end
end
--endregion

--region math
function math.round(number, precision)
	local mult = 10 ^ (precision or 0)

	return math.floor(number * mult + 0.5) / mult
end
--endregion

--region angle
--- @class angle_c
--- @field public p number Angle pitch.
--- @field public y number Angle yaw.
--- @field public r number Angle roll.
local angle_c = {}
local angle_mt = {
	__index = angle_c
}

--- Overwrite the angle's angles. Nil values leave the angle unchanged.
--- @param angle angle_c
--- @param p_new number
--- @param y_new number
--- @param r_new number
--- @return void
angle_mt.__call = function(angle, p_new, y_new, r_new)
	p_new = p_new or angle.p
	y_new = y_new or angle.y
	r_new = r_new or angle.r

	angle.p = p_new
	angle.y = y_new
	angle.r = r_new
end

--- Create a new vector object.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_c
local function angle(p, y, r)
	return setmetatable(
		{
			p = p or 0,
			y = y or 0,
			r = r or 0
		},
		angle_mt
	)
end

--- Overwrite the angle's angles. Nil values leave the angle unchanged.
--- @param p number
--- @param y number
--- @param r number
--- @return void
function angle_c:set(p, y, r)
	p = p or self.p
	y = y or self.y
	r = r or self.r

	self.p = p
	self.y = y
	self.r = r
end

--- Offset the angle's angles. Nil values leave the angle unchanged.
--- @param p number
--- @param y number
--- @param r number
--- @return void
function angle_c:offset(p, y, r)
	p = self.p + p or 0
	y = self.y + y or 0
	r = self.r + r or 0

	self.p = self.p + p
	self.y = self.y + y
	self.r = self.r + r
end

--- Clone the angle object.
--- @return angle_c
function angle_c:clone()
	return setmetatable(
		{
			p = self.p,
			y = self.y,
			r = self.r
		},
		angle_mt
	)
end

--- Clone and offset the angle's angles. Nil values leave the angle unchanged.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_c
function angle_c:clone_offset(p, y, r)
	p = self.p + p or 0
	y = self.y + y or 0
	r = self.r + r or 0

	return angle(
		self.p + p,
		self.y + y,
		self.r + r
	)
end

--- Clone the angle and optionally override its coordinates.
--- @param p number
--- @param y number
--- @param r number
--- @return angle_c
function angle_c:clone_set(p, y, r)
	p = p or self.p
	y = y or self.y
	r = r or self.r

	return angle(
		p,
		y,
		r
	)
end

--- Unpack the angle.
--- @return number, number, number
function angle_c:unpack()
	return self.p, self.y, self.r
end

--- Set the angle's euler angles to 0.
--- @return void
function angle_c:nullify()
	self.p = 0
	self.y = 0
	self.r = 0
end

--- Returns a string representation of the angle.
function angle_mt.__tostring(operand_a)
	return string.format("%s, %s, %s", operand_a.p, operand_a.y, operand_a.r)
end

--- Concatenates the angle in a string.
function angle_mt.__concat(operand_a)
	return string.format("%s, %s, %s", operand_a.p, operand_a.y, operand_a.r)
end

--- Adds the angle to another angle.
function angle_mt.__add(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a + operand_b.p,
			operand_a + operand_b.y,
			operand_a + operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p + operand_b,
			operand_a.y + operand_b,
			operand_a.r + operand_b
		)
	end

	return angle(
		operand_a.p + operand_b.p,
		operand_a.y + operand_b.y,
		operand_a.r + operand_b.r
	)
end

--- Subtracts the angle from another angle.
function angle_mt.__sub(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a - operand_b.p,
			operand_a - operand_b.y,
			operand_a - operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p - operand_b,
			operand_a.y - operand_b,
			operand_a.r - operand_b
		)
	end

	return angle(
		operand_a.p - operand_b.p,
		operand_a.y - operand_b.y,
		operand_a.r - operand_b.r
	)
end

--- Multiplies the angle with another angle.
function angle_mt.__mul(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a * operand_b.p,
			operand_a * operand_b.y,
			operand_a * operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p * operand_b,
			operand_a.y * operand_b,
			operand_a.r * operand_b
		)
	end

	return angle(
		operand_a.p * operand_b.p,
		operand_a.y * operand_b.y,
		operand_a.r * operand_b.r
	)
end

--- Divides the angle by the another angle.
function angle_mt.__div(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a / operand_b.p,
			operand_a / operand_b.y,
			operand_a / operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p / operand_b,
			operand_a.y / operand_b,
			operand_a.r / operand_b
		)
	end

	return angle(
		operand_a.p / operand_b.p,
		operand_a.y / operand_b.y,
		operand_a.r / operand_b.r
	)
end

--- Raises the angle to the power of an another angle.
function angle_mt.__pow(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			math.pow(operand_a, operand_b.p),
			math.pow(operand_a, operand_b.y),
			math.pow(operand_a, operand_b.r)
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			math.pow(operand_a.p, operand_b),
			math.pow(operand_a.y, operand_b),
			math.pow(operand_a.r, operand_b)
		)
	end

	return angle(
		math.pow(operand_a.p, operand_b.p),
		math.pow(operand_a.y, operand_b.y),
		math.pow(operand_a.r, operand_b.r)
	)
end

--- Performs modulo on the angle with another angle.
function angle_mt.__mod(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return angle(
			operand_a % operand_b.p,
			operand_a % operand_b.y,
			operand_a % operand_b.r
		)
	end

	if (type(operand_b) == "number") then
		return angle(
			operand_a.p % operand_b,
			operand_a.y % operand_b,
			operand_a.r % operand_b
		)
	end

	return angle(
		operand_a.p % operand_b.p,
		operand_a.y % operand_b.y,
		operand_a.r % operand_b.r
	)
end

--- Perform a unary minus operation on the angle.
function angle_mt.__unm(operand_a)
	return angle(
		-operand_a.p,
		-operand_a.y,
		-operand_a.r
	)
end

--- Clamps the angles to whole numbers. Equivalent to "angle:round" with no precision.
--- @return void
function angle_c:round_zero()
	self.p = math.floor(self.p + 0.5)
	self.y = math.floor(self.y + 0.5)
	self.r = math.floor(self.r + 0.5)
end

--- Round the angles.
--- @param precision number
function angle_c:round(precision)
	self.p = math.round(self.p, precision)
	self.y = math.round(self.y, precision)
	self.r = math.round(self.r, precision)
end

--- Clamps the angles to the nearest base.
--- @param base number
function angle_c:round_base(base)
	self.p = base * math.round(self.p / base)
	self.y = base * math.round(self.y / base)
	self.r = base * math.round(self.r / base)
end

--- Clamps the angles to whole numbers. Equivalent to "angle:round" with no precision.
--- @return angle_c
function angle_c:rounded_zero()
	return angle(
		math.floor(self.p + 0.5),
		math.floor(self.y + 0.5),
		math.floor(self.r + 0.5)
	)
end

--- Round the angles.
--- @param precision number
--- @return angle_c
function angle_c:rounded(precision)
	return angle(
		math.round(self.p, precision),
		math.round(self.y, precision),
		math.round(self.r, precision)
	)
end

--- Clamps the angles to the nearest base.
--- @param base number
--- @return angle_c
function angle_c:rounded_base(base)
	return angle(
		base * math.round(self.p / base),
		base * math.round(self.y / base),
		base * math.round(self.r / base)
	)
end
--endregion

--region vector
--- @class vector_c
--- @field public x number X coordinate.
--- @field public y number Y coordinate.
--- @field public z number Z coordinate.
local vector_c = {}
local vector_mt = {
	__index = vector_c,
}

--- Overwrite the vector's coordinates. Nil will leave coordinates unchanged.
--- @param vector vector_c
--- @param x_new number
--- @param y_new number
--- @param z_new number
--- @return void
vector_mt.__call = function(vector, x_new, y_new, z_new)
	x_new = x_new or vector.x
	y_new = y_new or vector.y
	z_new = z_new or vector.z

	vector.x = x_new
	vector.y = y_new
	vector.z = z_new
end

--- Create a new vector object.
--- @param x number
--- @param y number
--- @param z number
--- @return vector_c
local function vector(x, y, z)
	return setmetatable(
		{
			x = x or 0,
			y = y or 0,
			z = z or 0
		},
		vector_mt
	)
end

--- Overwrite the vector's coordinates. Nil will leave coordinates unchanged.
--- @param x_new number
--- @param y_new number
--- @param z_new number
--- @return void
function vector_c:set(x_new, y_new, z_new)
	x_new = x_new or self.x
	y_new = y_new or self.y
	z_new = z_new or self.z

	self.x = x_new
	self.y = y_new
	self.z = z_new
end

--- Offset the vector's coordinates. Nil will leave the coordinates unchanged.
--- @param x_offset number
--- @param y_offset number
--- @param z_offset number
--- @return void
function vector_c:offset(x_offset, y_offset, z_offset)
	x_offset = x_offset or 0
	y_offset = y_offset or 0
	z_offset = z_offset or 0

	self.x = self.x + x_offset
	self.y = self.y + y_offset
	self.z = self.z + z_offset
end

--- Clone the vector object.
--- @return vector_c
function vector_c:clone()
	return setmetatable(
		{
			x = self.x,
			y = self.y,
			z = self.z
		},
		vector_mt
	)
end

--- Clone the vector object and offset its coordinates. Nil will leave the coordinates unchanged.
--- @param x_offset number
--- @param y_offset number
--- @param z_offset number
--- @return vector_c
function vector_c:clone_offset(x_offset, y_offset, z_offset)
	x_offset = x_offset or 0
	y_offset = y_offset or 0
	z_offset = z_offset or 0

	return setmetatable(
		{
			x = self.x + x_offset,
			y = self.y + y_offset,
			z = self.z + z_offset
		},
		vector_mt
	)
end

--- Clone the vector and optionally override its coordinates.
--- @param x_new number
--- @param y_new number
--- @param z_new number
--- @return vector_c
function vector_c:clone_set(x_new, y_new, z_new)
	x_new = x_new or self.x
	y_new = y_new or self.y
	z_new = z_new or self.z

	return vector(
		x_new,
		y_new,
		z_new
	)
end

--- Unpack the vector.
--- @return number, number, number
function vector_c:unpack()
	return self.x, self.y, self.z
end

--- Set the vector's coordinates to 0.
--- @return void
function vector_c:nullify()
	self.x = 0
	self.y = 0
	self.z = 0
end

--- Returns a string representation of the vector.
function vector_mt.__tostring(operand_a)
	return string.format("%s, %s, %s", operand_a.x, operand_a.y, operand_a.z)
end

--- Concatenates the vector in a string.
function vector_mt.__concat(operand_a)
	return string.format("%s, %s, %s", operand_a.x, operand_a.y, operand_a.z)
end

--- Returns true if the vector's coordinates are equal to another vector.
function vector_mt.__eq(operand_a, operand_b)
	return (operand_a.x == operand_b.x) and (operand_a.y == operand_b.y) and (operand_a.z == operand_b.z)
end

--- Returns true if the vector is less than another vector.
function vector_mt.__lt(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return (operand_a < operand_b.x) or (operand_a < operand_b.y) or (operand_a < operand_b.z)
	end

	if (type(operand_b) == "number") then
		return (operand_a.x < operand_b) or (operand_a.y < operand_b) or (operand_a.z < operand_b)
	end

	return (operand_a.x < operand_b.x) or (operand_a.y < operand_b.y) or (operand_a.z < operand_b.z)
end

--- Returns true if the vector is less than or equal to another vector.
function vector_mt.__le(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return (operand_a <= operand_b.x) or (operand_a <= operand_b.y) or (operand_a <= operand_b.z)
	end

	if (type(operand_b) == "number") then
		return (operand_a.x <= operand_b) or (operand_a.y <= operand_b) or (operand_a.z <= operand_b)
	end

	return (operand_a.x <= operand_b.x) or (operand_a.y <= operand_b.y) or (operand_a.z <= operand_b.z)
end

--- Add a vector to another vector.
function vector_mt.__add(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a + operand_b.x,
			operand_a + operand_b.y,
			operand_a + operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x + operand_b,
			operand_a.y + operand_b,
			operand_a.z + operand_b
		)
	end

	return vector(
		operand_a.x + operand_b.x,
		operand_a.y + operand_b.y,
		operand_a.z + operand_b.z
	)
end

--- Subtract a vector from another vector.
function vector_mt.__sub(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a - operand_b.x,
			operand_a - operand_b.y,
			operand_a - operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x - operand_b,
			operand_a.y - operand_b,
			operand_a.z - operand_b
		)
	end

	return vector(
		operand_a.x - operand_b.x,
		operand_a.y - operand_b.y,
		operand_a.z - operand_b.z
	)
end

--- Multiply a vector with another vector.
function vector_mt.__mul(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a * operand_b.x,
			operand_a * operand_b.y,
			operand_a * operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x * operand_b,
			operand_a.y * operand_b,
			operand_a.z * operand_b
		)
	end

	return vector(
		operand_a.x * operand_b.x,
		operand_a.y * operand_b.y,
		operand_a.z * operand_b.z
	)
end

--- Divide a vector by another vector.
function vector_mt.__div(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a / operand_b.x,
			operand_a / operand_b.y,
			operand_a / operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x / operand_b,
			operand_a.y / operand_b,
			operand_a.z / operand_b
		)
	end

	return vector(
		operand_a.x / operand_b.x,
		operand_a.y / operand_b.y,
		operand_a.z / operand_b.z
	)
end

--- Raised a vector to the power of another vector.
function vector_mt.__pow(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			math.pow(operand_a, operand_b.x),
			math.pow(operand_a, operand_b.y),
			math.pow(operand_a, operand_b.z)
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			math.pow(operand_a.x, operand_b),
			math.pow(operand_a.y, operand_b),
			math.pow(operand_a.z, operand_b)
		)
	end

	return vector(
		math.pow(operand_a.x, operand_b.x),
		math.pow(operand_a.y, operand_b.y),
		math.pow(operand_a.z, operand_b.z)
	)
end

--- Performs a modulo operation on a vector with another vector.
function vector_mt.__mod(operand_a, operand_b)
	if (type(operand_a) == "number") then
		return vector(
			operand_a % operand_b.x,
			operand_a % operand_b.y,
			operand_a % operand_b.z
		)
	end

	if (type(operand_b) == "number") then
		return vector(
			operand_a.x % operand_b,
			operand_a.y % operand_b,
			operand_a.z % operand_b
		)
	end

	return vector(
		operand_a.x % operand_b.x,
		operand_a.y % operand_b.y,
		operand_a.z % operand_b.z
	)
end

--- Perform a unary minus operation on the vector.
function vector_mt.__unm(operand_a)
	return vector(
		-operand_a.x,
		-operand_a.y,
		-operand_a.z
	)
end

--- Returns the vector's 2 dimensional length squared.
--- @return number
function vector_c:length2_squared()
	return (self.x * self.x) + (self.y * self.y);
end

--- Return's the vector's 2 dimensional length.
--- @return number
function vector_c:length2()
	return math.sqrt(self:length2_squared())
end

--- Returns the vector's 3 dimensional length squared.
--- @return number
function vector_c:length_squared()
	return (self.x * self.x) + (self.y * self.y) + (self.z * self.z);
end

--- Return's the vector's 3 dimensional length.
--- @return number
function vector_c:length()
	return math.sqrt(self:length_squared())
end

--- Returns the vector's dot product.
--- @param b vector_c
--- @return number
function vector_c:dot_product(b)
	return (self.x * b.x) + (self.y * b.y) + (self.z * b.z)
end

--- Returns the vector's cross product.
--- @param b vector_c
--- @return vector_c
function vector_c:cross_product(b)
	return vector(
		(self.y * b.z) - (self.z * b.y),
		(self.z * b.x) - (self.x * b.z),
		(self.x * b.y) - (self.y * b.x)
	)
end

--- Returns the 2 dimensional distance between the vector and another vector.
--- @param destination vector_c
--- @return number
function vector_c:distance2(destination)
	return (destination - self):length2()
end

--- Returns the 3 dimensional distance between the vector and another vector.
--- @param destination vector_c
--- @return number
function vector_c:distance(destination)
	return (destination - self):length()
end

--- Returns the distance on the X axis between the vector and another vector.
--- @param destination vector_c
--- @return number
function vector_c:distance_x(destination)
	return math.abs(self.x - destination.x)
end

--- Returns the distance on the Y axis between the vector and another vector.
--- @param destination vector_c
--- @return number
function vector_c:distance_y(destination)
	return math.abs(self.y - destination.y)
end

--- Returns the distance on the Z axis between the vector and another vector.
--- @param destination vector_c
--- @return number
function vector_c:distance_z(destination)
	return math.abs(self.z - destination.z)
end

--- Returns true if the vector is within the given distance to another vector.
--- @param destination vector_c
--- @param distance number
--- @return boolean
function vector_c:in_range(destination, distance)
	return self:distance(destination) <= distance
end

--- Clamps the vector's coordinates to whole numbers. Equivalent to "vector:round" with no precision.
--- @return void
function vector_c:round_zero()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
	self.z = math.floor(self.z + 0.5)
end

--- Round the vector's coordinates.
--- @param precision number
--- @return void
function vector_c:round(precision)
	self.x = math.round(self.x, precision)
	self.y = math.round(self.y, precision)
	self.z = math.round(self.z, precision)
end

--- Clamps the vector's coordinates to the nearest base.
--- @param base number
--- @return void
function vector_c:round_base(base)
	self.x = base * math.round(self.x / base)
	self.y = base * math.round(self.y / base)
	self.z = base * math.round(self.z / base)
end

--- Clamps the vector's coordinates to whole numbers. Equivalent to "vector:round" with no precision.
--- @return vector_c
function vector_c:rounded_zero()
	return vector(
		math.floor(self.x + 0.5),
		math.floor(self.y + 0.5),
		math.floor(self.z + 0.5)
	)
end

--- Round the vector's coordinates.
--- @param precision number
--- @return vector_c
function vector_c:rounded(precision)
	return vector(
		math.round(self.x, precision),
		math.round(self.y, precision),
		math.round(self.z, precision)
	)
end

--- Clamps the vector's coordinates to the nearest base.
--- @param base number
--- @return vector_c
function vector_c:rounded_base(base)
	return vector(
		base * math.round(self.x / base),
		base * math.round(self.y / base),
		base * math.round(self.z / base)
	)
end

--- Normalize the vector.
--- @return void
function vector_c:normalize()
	local length = self:length()

	-- Prevent possible divide-by-zero errors.
	if (length ~= 0) then
		self.x = self.x / length
		self.y = self.y / length
		self.z = self.z / length
	else
		self.x = 0
		self.y = 0
		self.z = 1
	end
end

--- Returns the normalized length of a vector.
--- @return number
function vector_c:normalized_length()
	return self:length()
end

--- Returns a copy of the vector, normalized.
--- @return vector_c
function vector_c:normalized()
	local length = self:length()

	if (length ~= 0) then
		return vector(
			self.x / length,
			self.y / length,
			self.z / length
		)
	else
		return vector(0, 0, 1)
	end
end

--- Returns a new 2 dimensional vector of the original vector when mapped to the screen, or nil if the vector is off-screen.
--- @return vector_c
function vector_c:to_screen(only_within_screen_boundary)
	local x, y = renderer.world_to_screen(self.x, self.y, self.z)

	if (x == nil or y == nil) then
		return nil
	end

	if (only_within_screen_boundary == true) then
		local screen_x, screen_y = client.screen_size()

		if (x < 0 or x > screen_x or y < 0 or y > screen_y) then
			return nil
		end
	end

	return vector(x, y)
end

--- Returns the magnitude of the vector, use this to determine the speed of the vector if it's a velocity vector.
--- @return number
function vector_c:magnitude()
	return math.sqrt(
		math.pow(self.x, 2) +
			math.pow(self.y, 2) +
			math.pow(self.z, 2)
	)
end

--- Returns the angle of the vector in regards to another vector.
--- @param destination vector_c
--- @return angle_c
function vector_c:angle_to(destination)
	-- Calculate the delta of vectors.
	local delta_vector = vector(destination.x - self.x, destination.y - self.y, destination.z - self.z)

	-- Calculate the yaw.
	local yaw = math.deg(math.atan2(delta_vector.y, delta_vector.x))

	-- Calculate the pitch.
	local hyp = math.sqrt(delta_vector.x * delta_vector.x + delta_vector.y * delta_vector.y)
	local pitch = math.deg(math.atan2(-delta_vector.z, hyp))

	return angle(pitch, yaw)
end

--- Lerp to another vector.
--- @param destination vector_c
--- @param percentage number
--- @return vector_c
function vector_c:lerp(destination, percentage)
	return self + (destination - self) * percentage
end

--- Internally divide a ray.
--- @param source vector_c
--- @param destination vector_c
--- @param m number
--- @param n number
--- @return vector_c
local function vector_internal_division(source, destination, m, n)
	return vector((source.x * n + destination.x * m) / (m + n),
		(source.y * n + destination.y * m) / (m + n),
		(source.z * n + destination.z * m) / (m + n))
end

--- Returns the result of client.trace_line between two vectors.
--- @param destination vector_c
--- @param skip_entindex number
--- @return number, number|nil
function vector_c:trace_line_to(destination, skip_entindex)
	skip_entindex = skip_entindex or -1

	return client.trace_line(
		skip_entindex,
		self.x,
		self.y,
		self.z,
		destination.x,
		destination.y,
		destination.z
	)
end

--- Trace line to another vector and returns the fraction, entity, and the impact point.
--- @param destination vector_c
--- @param skip_entindex number
--- @return number, number, vector_c
function vector_c:trace_line_impact(destination, skip_entindex)
	skip_entindex = skip_entindex or -1

	local fraction, eid = client.trace_line(skip_entindex, self.x, self.y, self.z, destination.x, destination.y, destination.z)
	local impact = self:lerp(destination, fraction)

	return fraction, eid, impact
end

--- Trace line to another vector, skipping any entity indices returned by the callback and returns the fraction, entity, and the impact point.
--- @param destination vector_c
--- @param callback fun(eid: number): boolean
--- @param max_traces number
--- @return number, number, vector_c
function vector_c:trace_line_skip_indices(destination, max_traces, callback)
	max_traces = max_traces or 10

	local fraction, eid = 0, -1
	local impact = self
	local i = 0

	while (max_traces >= i and fraction < 1 and ((eid > -1 and callback(eid)) or impact == self)) do
		fraction, eid, impact = impact:trace_line_impact(destination, eid)
		i = i + 1
	end

	return self:distance(impact) / self:distance(destination), eid, impact
end

--- Traces a line from source to destination and returns the fraction, entity, and the impact point.
--- @param destination vector_c
--- @param skip_classes table
--- @param skip_distance number
--- @return number, number
function vector_c:trace_line_skip_class(destination, skip_classes, skip_distance)
	local should_skip = function(index, skip_entity)
		local class_name = entity.get_classname(index) or ""
		for i in 1, #skip_entity do
			if class_name == skip_entity[i] then
				return true
			end
		end

		return false
	end

	local angles = self:angle_to(destination)
	local direction = angles:to_forward_vector()

	local last_traced_position = self

	while true do  -- Start tracing.
		local fraction, hit_entity = last_traced_position:trace_line_to(destination)

		if fraction == 1 and hit_entity == -1 then  -- If we didn't hit anything.
			return 1, -1  -- return nothing.
		else  -- BOIS WE HIT SOMETHING.
			if should_skip(hit_entity, skip_classes) then  -- If entity should be skipped.
				-- Set last traced position according to fraction.
				last_traced_position = vector_internal_division(self, destination, fraction, 1 - fraction)

				-- Add a little gap per each trace to prevent inf loop caused by intersection.
				last_traced_position = last_traced_position + direction * skip_distance
			else  -- That's the one I want.
				return fraction, hit_entity, self:lerp(destination, fraction)
			end
		end
	end
end

--- Returns the result of client.trace_bullet between two vectors.
--- @param eid number
--- @param destination vector_c
--- @return number|nil, number
function vector_c:trace_bullet_to(destination, eid)
	return client.trace_bullet(
		eid,
		self.x,
		self.y,
		self.z,
		destination.x,
		destination.y,
		destination.z
	)
end

--- Returns the vector of the closest point along a ray.
--- @param ray_start vector_c
--- @param ray_end vector_c
--- @return vector_c
function vector_c:closest_ray_point(ray_start, ray_end)
	local to = self - ray_start
	local direction = ray_end - ray_start
	local length = direction:length()

	direction:normalize()

	local ray_along = to:dot_product(direction)

	if (ray_along < 0) then
		return ray_start
	elseif (ray_along > length) then
		return ray_end
	end

	return ray_start + direction * ray_along
end

--- Returns a point along a ray after dividing it.
--- @param ray_end vector_c
--- @param ratio number
--- @return vector_c
function vector_c:ray_divided(ray_end, ratio)
	return (self * ratio + ray_end) / (1 + ratio)
end

--- Returns a ray divided into a number of segments.
--- @param ray_end vector_c
--- @param segments number
--- @return table<number, vector_c>
function vector_c:ray_segmented(ray_end, segments)
	local points = {}

	for i = 0, segments do
		points[i] = vector_internal_division(self, ray_end, i, segments - i)
	end

	return points
end

--- Returns the best source vector and destination vector to draw a line on-screen using world-to-screen.
--- @param ray_end vector_c
--- @param total_segments number
--- @return vector_c|nil, vector_c|nil
function vector_c:ray(ray_end, total_segments)
	total_segments = total_segments or 128

	local segments = {}
	local step = self:distance(ray_end) / total_segments
	local angle = self:angle_to(ray_end)
	local direction = angle:to_forward_vector()

	for i = 1, total_segments do
		table.insert(segments, self + (direction * (step * i)))
	end

	local src_screen_position = vector(0, 0, 0)
	local dst_screen_position = vector(0, 0, 0)
	local src_in_screen = false
	local dst_in_screen = false

	for i = 1, #segments do
		src_screen_position = segments[i]:to_screen()

		if src_screen_position ~= nil then
			src_in_screen = true

			break
		end
	end

	for i = #segments, 1, -1 do
		dst_screen_position = segments[i]:to_screen()

		if dst_screen_position ~= nil then
			dst_in_screen = true

			break
		end
	end

	if src_in_screen and dst_in_screen then
		return src_screen_position, dst_screen_position
	end

	return nil
end

--- Returns true if the ray goes through a smoke. False if not.
--- @param ray_end vector_c
--- @return boolean
function vector_c:ray_intersects_smoke(ray_end)
	if (line_goes_through_smoke == nil) then
		error("Unsafe scripts must be allowed in order to use vector_c:ray_intersects_smoke")
	end

	return line_goes_through_smoke(self.x, self.y, self.z, ray_end.x, ray_end.y, ray_end.z, 1)
end

--- Returns true if the vector lies within the boundaries of a given 2D polygon. The polygon is a table of vectors. The Z axis is ignored.
--- @param polygon table<any, vector_c>
--- @return boolean
function vector_c:inside_polygon2(polygon)
	local odd_nodes = false
	local polygon_vertices = #polygon
	local j = polygon_vertices

	for i = 1, polygon_vertices do
		if (polygon[i].y < self.y and polygon[j].y >= self.y or polygon[j].y < self.y and polygon[i].y >= self.y) then
			if (polygon[i].x + (self.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < self.x) then
				odd_nodes = not odd_nodes
			end
		end

		j = i
	end

	return odd_nodes
end

--- Draws a world circle with an origin of the vector. Code credited to sapphyrus.
--- @param radius number
--- @param r number
--- @param g number
--- @param b number
--- @param a number
--- @param accuracy number
--- @param width number
--- @param outline number
--- @param start_degrees number
--- @param percentage number
--- @return void
function vector_c:draw_circle(radius, r, g, b, a, accuracy, width, outline, start_degrees, percentage)
	local accuracy = accuracy ~= nil and accuracy or 3
	local width = width ~= nil and width or 1
	local outline = outline ~= nil and outline or false
	local start_degrees = start_degrees ~= nil and start_degrees or 0
	local percentage = percentage ~= nil and percentage or 1

	local screen_x_line_old, screen_y_line_old

	for rot = start_degrees, percentage * 360, accuracy do
		local rot_temp = math.rad(rot)
		local lineX, lineY, lineZ = radius * math.cos(rot_temp) + self.x, radius * math.sin(rot_temp) + self.y, self.z
		local screen_x_line, screen_y_line = renderer.world_to_screen(lineX, lineY, lineZ)
		if screen_x_line ~= nil and screen_x_line_old ~= nil then

			for i = 1, width do
				local i = i - 1

				renderer.line(screen_x_line, screen_y_line - i, screen_x_line_old, screen_y_line_old - i, r, g, b, a)
			end

			if outline then
				local outline_a = a / 255 * 160

				renderer.line(screen_x_line, screen_y_line - width, screen_x_line_old, screen_y_line_old - width, 16, 16, 16, outline_a)

				renderer.line(screen_x_line, screen_y_line + 1, screen_x_line_old, screen_y_line_old + 1, 16, 16, 16, outline_a)
			end
		end

		screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
	end
end

--- Performs math.min on the vector.
--- @param value number
--- @return void
function vector_c:min(value)
	self.x = math.min(value, self.x)
	self.y = math.min(value, self.y)
	self.z = math.min(value, self.z)
end

--- Performs math.max on the vector.
--- @param value number
--- @return void
function vector_c:max(value)
	self.x = math.max(value, self.x)
	self.y = math.max(value, self.y)
	self.z = math.max(value, self.z)
end

--- Performs math.min on the vector and returns the result.
--- @param value number
--- @return void
function vector_c:minned(value)
	return vector(
		math.min(value, self.x),
		math.min(value, self.y),
		math.min(value, self.z)
	)
end

--- Performs math.max on the vector and returns the result.
--- @param value number
--- @return void
function vector_c:maxed(value)
	return vector(
		math.max(value, self.x),
		math.max(value, self.y),
		math.max(value, self.z)
	)
end
--endregion

--region angle_vector_methods
--- Returns a forward vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_forward_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))

	return vector(cp * cy, cp * sy, -sp)
end

--- Return an up vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_up_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return vector(cr * sp * cy + sr * sy, cr * sp * sy + sr * cy * -1, cr * cp)
end

--- Return a right vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_right_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return vector(sr * sp * cy * -1 + cr * sy, sr * sp * sy * -1 + -1 * cr * cy, -1 * sr * cp)
end

--- Return a backward vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_backward_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))

	return -vector(cp * cy, cp * sy, -sp)
end

--- Return a left vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_left_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return -vector(sr * sp * cy * -1 + cr * sy, sr * sp * sy * -1 + -1 * cr * cy, -1 * sr * cp)
end

--- Return a down vector of the angle. Use this to convert an angle into a cartesian direction.
--- @return vector_c
function angle_c:to_down_vector()
	local degrees_to_radians = function(degrees)
		return degrees * math.pi / 180
	end

	local sp = math.sin(degrees_to_radians(self.p))
	local cp = math.cos(degrees_to_radians(self.p))
	local sy = math.sin(degrees_to_radians(self.y))
	local cy = math.cos(degrees_to_radians(self.y))
	local sr = math.sin(degrees_to_radians(self.r))
	local cr = math.cos(degrees_to_radians(self.r))

	return -vector(cr * sp * cy + sr * sy, cr * sp * sy + sr * cy * -1, cr * cp)
end

--- Calculate where a vector is in a given field of view.
--- @param source vector_c
--- @param destination vector_c
--- @return number
function angle_c:fov_to(source, destination)
	local fwd = self:to_forward_vector()
	local delta = (destination - source):normalized()
	local fov = math.acos(fwd:dot_product(delta) / delta:length())

	return math.max(0.0, math.deg(fov))
end

--- Returns the degrees bearing of the angle's yaw.
--- @param precision number
--- @return number
function angle_c:bearing(precision)
	local yaw = 180 - self.y + 90
	local degrees = (yaw % 360 + 360) % 360

	degrees = degrees > 180 and degrees - 360 or degrees

	return math.round(degrees + 180, precision)
end

--- Returns the yaw appropriate for renderer circle's start degrees.
--- @return number
function angle_c:start_degrees()
	local yaw = self.y
	local degrees = (yaw % 360 + 360) % 360

	degrees = degrees > 180 and degrees - 360 or degrees

	return degrees + 180
end

--- Returns a copy of the angles normalized and clamped.
--- @return number
function angle_c:normalize()
	local pitch = self.p

	if (pitch < -89) then
		pitch = -89
	elseif (pitch > 89) then
		pitch = 89
	end

	local yaw = self.y

	while yaw > 180 do
		yaw = yaw - 360
	end

	while yaw < -180 do
		yaw = yaw + 360
	end

	return angle(pitch, yaw, 0)
end

--- Normalizes and clamps the angles.
--- @return number
function angle_c:normalized()
	if (self.p < -89) then
		self.p = -89
	elseif (self.p > 89) then
		self.p = 89
	end

	local yaw = self.y

	while yaw > 180 do
		yaw = yaw - 360
	end

	while yaw < -180 do
		yaw = yaw + 360
	end

	self.y = yaw
	self.r = 0
end
--endregion

--region functions
--- Draws a polygon to the screen.
--- @param polygon table<number, vector_c>
--- @return void
function vector_c.draw_polygon(polygon, r, g, b, a, segments)
	for id, vertex in pairs(polygon) do
		local next_vertex = polygon[id + 1]

		if (next_vertex == nil) then
			next_vertex = polygon[1]
		end

		local ray_a, ray_b = vertex:ray(next_vertex, (segments or 64))

		if (ray_a ~= nil and ray_b ~= nil) then
			renderer.line(
				ray_a.x, ray_a.y,
				ray_b.x, ray_b.y,
				r, g, b, a
			)
		end
	end
end

--- Returns the eye position of a player.
--- @param eid number
--- @return vector_c
function vector_c.eye_position(eid)
	local origin = vector(entity.get_origin(eid))
	local duck_amount = entity.get_prop(eid, "m_flDuckAmount") or 0

	origin.z = origin.z + 46 + (1 - duck_amount) * 18

	return origin
end
--endregion
--endregion

local ui_get, ui_set, ui_ref = ui.get, ui.set, ui.reference
local client_get_cvar, client_set_cvar = client.get_cvar, client.set_cvar
local ent_get_prop, ent_get_local = entity.get_prop, entity.get_local_player
local globals_curtime = globals.curtime
local globals_tickcount = globals.tickcount
local entity_get_player_weapon = entity.get_player_weapon
local interval_per_tick = globals.tickinterval
local entity_get_players = entity.get_players

local hotkey = ui.new_checkbox("lua", "b", "Enable Anti-Aim")
local ui_resetaa = ui.new_combobox("lua", "b", "Fake Type", "Normal", "Ideal", "Manual")
local ui_syncaa = ui.new_combobox("lua", "b", "Sync Fake", "Off", "On")

local chkbox_nervoswalk = ui.new_checkbox("lua", "b", "Slow Walk")
local hotkey_nervoswalk = ui.new_hotkey("lua", "b", "Key")
local slider_nervoswalk = ui.new_slider("lua", "b", "Speed", 1, 245, 40, true, "%")

local ui_left_hotkey = ui.new_hotkey("lua", "b", "Left key")
local ui_left_mode = ui.new_combobox("lua", "b", "Left mode", "Static", "Jitter")
local ui_right_hotkey = ui.new_hotkey("lua", "b", "Right key")
local ui_right_mode = ui.new_combobox("lua", "b", "Right mode", "Static", "Jitter")
local ui_backwards_hotkey = ui.new_hotkey("lua", "b", "Backwards key")
local ui_backwards_mode = ui.new_combobox("lua", "b", "Backwards mode", "Static")
local ui_freestanding_hotkey = ui.new_hotkey("lua", "b", "Freestanding key")
local ui_indicator_combobox = ui.new_combobox("lua", "b", "Anti-aim indicator", "Off", "On")
local ui_indicator_color_picker = ui.new_color_picker("lua", "b", "Indicator color", "0", "115", "255", "255")

-- client vars
local client_log = client.log
local client_draw_text = client.draw_text
local client_screensize = client.screen_size
local client_set_event_callback = client.set_event_callback

-- anti-aim references
local yaw_reference, yaw_val_reference = ui_ref("AA", "Anti-aimbot angles", "Yaw")
local yaw_jitter_reference, yaw_jitter_val_reference = ui_ref("AA", "Anti-aimbot angles", "Yaw jitter")
local yaw_base_reference = ui_ref("AA", "Anti-aimbot angles", "Yaw base")
local reference_fake, reference_fake_slider = ui_ref("AA", "Anti-aimbot angles", "body yaw")
local freestanding_reference = ui_ref("AA", "Anti-aimbot angles", "Freestanding")
local on_shot_ref = ui.reference("AA", "Other", "On shot anti-aim")
local duck_peek_ref = ui.reference("RAGE", "Other", "Duck peek assist")
local lua_enabled = ui.new_checkbox("LUA", "B", "Automatic inverter")
local on_peek = ui.new_checkbox("LUA", "B", "On Peek/Getting peeked ONLY")
local prediction_ticks = ui.new_slider("LUA", "B", "AA Ticks", 5, 30,20)



local tickcount = globals_tickcount
local lasttick = tickcount()

local nextAttack = 0
local nextShotSecondary = 0
local nextShot = 0
local ref_doubletap = { ui.reference("RAGE", "Other", "Double Tap") }

local function is_dt()

	local dt = false

	local local_player = entity.get_local_player()

	if local_player == nil then
		return
	end

	if not entity.is_alive(local_player) then
		return
	end

	local active_weapon = entity.get_prop(local_player, "m_hActiveWeapon")

	if active_weapon == nil then
		return
	end

    nextAttack = entity.get_prop(local_player,"m_flNextAttack")
	nextShot = entity.get_prop(active_weapon,"m_flNextPrimaryAttack")
	nextShotSecondary = entity.get_prop(active_weapon,"m_flNextSecondaryAttack")

	if nextAttack == nil or nextShot == nil or nextShotSecondary == nil then
		return
	end

	nextAttack = nextAttack + 0.5
	nextShot = nextShot + 0.5
	nextShotSecondary = nextShotSecondary + 0.5

	if ui.get(ref_doubletap[1]) and ui.get(ref_doubletap[2]) then
		if math.max(nextShot,nextShotSecondary) < nextAttack then -- swapping
			if nextAttack - globals.curtime() > 0.00 then
				dt = false --client.draw_indicator(ctx, 255, 0, 0, 255, "DT")
			else
				dt = true --client.draw_indicator(ctx, 0, 255, 0, 255, "DT")
			end
		else -- shooting or just shot
			if math.max(nextShot,nextShotSecondary) - globals.curtime() > 0.00  then
				dt = false --client.draw_indicator(ctx, 255, 0, 0, 255, "DT")
			else
				if math.max(nextShot,nextShotSecondary) - globals.curtime() < 0.00  then
					dt = true --client.draw_indicator(ctx, 0, 255, 0, 255, "DT")
				else
					dt = true --client.draw_indicator(ctx, 0, 255, 0, 255, "DT")
				end
			end
		end
	end

	return dt
end

local function timer(delay, f)
    local now = tickcount()
    if lasttick < now - delay then
        f()
        lasttick = now
    end
end

local function clamp(min, max, current)
    if current > max then
        current = max
    elseif current < min then
        current = min
    end
    return math.floor(current)
end

local function IsNumberNegative(intNumber)
    if(string.sub(tostring(intNumber), 1, 1) == "-") then
        return true;
    else
        return false
    end
    return nil
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

local function calc_angle(x_src, y_src, z_src, x_dst, y_dst, z_dst)
    local x_delta = x_src - x_dst
    local y_delta = y_src - y_dst
    local z_delta = z_src - z_dst
    local hyp = math.sqrt(x_delta^2 + y_delta^2)
    local x = math.atan2(z_delta, hyp) * 57.295779513082
    local y = math.atan2( y_delta , x_delta) * 180 / 3.14159265358979323846

    if y > 180 then
        y = y - 180
    end
    if y < -180 then
        y = y + 180
    end
    return y
end

local function get_near_target()
	local enemy_players = entity.get_players(true)
	if #enemy_players ~= 0 then
		local own_x, own_y, own_z = client.eye_position()
		local own_pitch, own_yaw = client.camera_angles()
		local closest_enemy = nil
		local closest_distance = 999999999

		for i = 1, #enemy_players do
			local enemy = enemy_players[i]
			local enemy_x, enemy_y, enemy_z = entity.get_prop(enemy, "m_vecOrigin")

			local x = enemy_x - own_x
			local y = enemy_y - own_y
			local z = enemy_z - own_z

			local yaw = ((math.atan2(y, x) * 180 / math.pi))
			local pitch = -(math.atan2(z, math.sqrt(math.pow(x, 2) + math.pow(y, 2))) * 180 / math.pi)

			local yaw_dif = math.abs(own_yaw % 360 - yaw % 360) % 360
			local pitch_dif = math.abs(own_pitch - pitch ) % 360

			if yaw_dif > 180 then yaw_dif = 360 - yaw_dif end
			local real_dif = math.sqrt(math.pow(yaw_dif, 2) + math.pow(pitch_dif, 2))

			if closest_distance > real_dif then
				closest_distance = real_dif
				closest_enemy = enemy
			end
		end

		if closest_enemy ~= nil then
			return closest_enemy, closest_distance
		end
	end

	return nil, nil
end

local function normalise_angle(angle)
    angle =  angle % 360
    angle = (angle + 360) % 360
    if (angle > 180)  then
        angle = angle - 360
    end
    return angle
end

local function is_crouching(ent)
	local flags = ent_get_prop(ent, "m_fFlags")
	local crouching = bit.band(flags, 4)

	if crouching == 4 then
		return true
	end

	return false
end


local function setSpeed(newSpeed)
	if newSpeed == 245 then
		return
	end
	local LocalPlayer = ent_get_local
	local vx, vy = ent_get_prop(LocalPlayer(), "m_vecVelocity")
	local velocity = math.floor(math.min(10000, math.sqrt(vx*vx + vy*vy) + 0.5))
	--client.log(velocity)
	local maxvelo = newSpeed

	if(velocity<maxvelo) then
		client_set_cvar("cl_sidespeed", maxvelo)
		client_set_cvar("cl_forwardspeed", maxvelo)
		client_set_cvar("cl_backspeed", maxvelo)
	end

	if(velocity>=maxvelo) then
		local kat=math.atan2(client_get_cvar("cl_forwardspeed"), client_get_cvar("cl_sidespeed"))
		local forward=math.cos(kat)*maxvelo;
		local side=math.sin(kat)*maxvelo;
		client_set_cvar("cl_sidespeed", side)
		client_set_cvar("cl_forwardspeed", forward)
		client_set_cvar("cl_backspeed", forward)
	end
end

-- anti-aim direction/mode bools
local isLeft, isRight, isBack, isFreestanding = false
isBack = true
local deg = 0
-- gets the current antiaim dir/mode
local function get_antiaim_dir()
	if not (ui_get(ui_resetaa) == "Manual" or ui_get(ui_resetaa) == "Normal") and isBack then
		isRight = true
		isFreestanding, isLeft, isBack = false

	end
	if ui.get(lua_enabled) then return end
	if ui_get(ui_freestanding_hotkey) then
		isFreestanding = true
		isLeft, isRight, isBack = false
	elseif ui_get(ui_left_hotkey) then
		isLeft = true
		isFreestanding, isRight, isBack = false
	elseif ui_get(ui_right_hotkey) then
		isRight = true
		isFreestanding, isLeft, isBack = false
	elseif ui_get(ui_backwards_hotkey) and (ui_get(ui_resetaa) == "Manual" or ui_get(ui_resetaa) == "Normal") then
		isBack = true
		isFreestanding, isLeft, isRight = false
	end
end

-- sets the ui values for manual left
local function setLeft()
if ui_get(ui_left_mode) == "Static" then
	ui_set(yaw_reference, "180")

	if ui_get(ui_resetaa) == "Normal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, 141)
	elseif ui_get(ui_resetaa) == "Ideal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, 141)
	elseif ui_get(ui_resetaa) == "Manual" then
		ui_set(yaw_val_reference, -90)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, 0)
		ui_set(yaw_jitter_reference, "off")
	end

	ui_set(freestanding_reference, false)

	if ui_get(ui_syncaa) == "On" then
		ui_set(yaw_base_reference, "At targets")
	elseif ui_get(ui_syncaa) == "Off" then
		ui_set(yaw_base_reference, "Local view")
	end
elseif ui_get(ui_left_mode) == "Jitter" then
	ui_set(yaw_reference, "180")

	if ui_get(ui_resetaa) == "Normal" then
		ui_set(yaw_val_reference, -21)
		ui_set(reference_fake, "jitter")
		ui_set(reference_fake_slider, 109)
		ui_set(yaw_jitter_reference, "off")
	elseif ui_get(ui_resetaa) == "Ideal" then
		ui_set(yaw_val_reference, -8)
		ui_set(reference_fake, "jitter")
		ui_set(reference_fake_slider, 100)
		ui_set(yaw_jitter_reference, "off")
	elseif ui_get(ui_resetaa) == "Manual" then
		ui_set(yaw_val_reference, -90)
		ui_set(reference_fake, "Jitter")
		ui_set(reference_fake_slider, 95)
		ui_set(yaw_jitter_reference, "off")
	end

	ui_set(freestanding_reference, false)

	if ui_get(ui_syncaa) == "On" then
		ui_set(yaw_base_reference, "At targets")
	elseif ui_get(ui_syncaa) == "Off" then
		ui_set(yaw_base_reference, "Local view")
	end
end
end

-- sets the ui values for manual right
local function setRight()
if ui_get(ui_right_mode) == "Static" then
	ui_set(yaw_reference, "180")

	if ui_get(ui_resetaa) == "Normal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, -141)
	elseif ui_get(ui_resetaa) == "Ideal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, -141)
	elseif ui_get(ui_resetaa) == "Manual" then
		ui_set(yaw_val_reference, 90)
		ui_set(reference_fake, "static")
		ui_set(reference_fake_slider, 0)
		ui_set(yaw_jitter_reference, "off")
	end

	ui_set(freestanding_reference, false)

	if ui_get(ui_syncaa) == "On" then
		ui_set(yaw_base_reference, "At targets")
	elseif ui_get(ui_syncaa) == "Off" then
		ui_set(yaw_base_reference, "Local view")
	end

elseif ui_get(ui_right_mode) == "Jitter" then
	ui_set(yaw_reference, "180")

	if ui_get(ui_resetaa) == "Normal" then
		ui_set(yaw_val_reference, 33)
		ui_set(reference_fake, "jitter")
		ui_set(reference_fake_slider, -109)
		ui_set(yaw_jitter_reference, "off")
	elseif ui_get(ui_resetaa) == "Ideal" then
		ui_set(yaw_val_reference, -5)
		ui_set(reference_fake, "jitter")
		ui_set(reference_fake_slider, 44)
		ui_set(yaw_jitter_reference, "off")
	elseif ui_get(ui_resetaa) == "Manual" then
		ui_set(yaw_val_reference, 90)
		ui_set(reference_fake, "Jitter")
		ui_set(reference_fake_slider, 95)
		ui_set(yaw_jitter_reference, "off")
	end

	ui_set(freestanding_reference, false)

	if ui_get(ui_syncaa) == "On" then
		ui_set(yaw_base_reference, "At targets")
	elseif ui_get(ui_syncaa) == "Off" then
		ui_set(yaw_base_reference, "Local view")
	end
end
end


-- sets the ui values for manual back
local function setBack()
if ui_get(ui_backwards_mode) == "Static" then
	ui_set(yaw_reference, "180")
	if ui_get(ui_resetaa) == "Normal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "Jitter")
		ui_set(reference_fake_slider, 95)
		ui_set(yaw_jitter_reference, "offset")
		ui_set(yaw_jitter_val_reference, 0)
	elseif ui_get(ui_resetaa) == "Manual" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "opposite")
		ui_set(yaw_jitter_reference, "offset")
		ui_set(yaw_jitter_val_reference, 0)

	elseif ui_get(ui_resetaa) == "Ideal" then
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "Jitter")
		ui_set(reference_fake_slider, 95)
		ui_set(yaw_jitter_reference, "offset")
		ui_set(yaw_jitter_val_reference, 0)
	end
end

	ui_set(freestanding_reference, false)

	if ui_get(ui_syncaa) == "On" then
		ui_set(yaw_base_reference, "At targets")
	elseif ui_get(ui_syncaa) == "Off" then
		ui_set(yaw_base_reference, "Local view")
	end
end


-- sets the ui values for freestanding
local function setFreestanding()
	ui_set(yaw_reference, "180")
	ui_set(yaw_base_reference, "local view")
	ui_set(yaw_val_reference, 0)
	ui_set(reference_fake, "opposite")
	ui_set(yaw_jitter_reference, "offset")
	ui_set(yaw_jitter_val_reference, 10)
	ui_set(freestanding_reference, true)


end


local function distance_3d(x1,y1,z1,x2,y2,z2)
	return math.sqrt( (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) )
end
local function extrapolate(player , ticks , x,y,z )
	local xv,yv,zv =  entity.get_prop(player, "m_vecVelocity")
	local new_x = x + globals.tickinterval() * xv * ticks
	local new_y = y + globals.tickinterval() * yv * ticks
	local new_z = z + globals.tickinterval() * zv * ticks
	return new_x,new_y,new_z

end

local function is_enemy_peeking(player)
	local vx,vy,vz = entity.get_prop(player, "m_vecVelocity")
	local speed = math.sqrt(vx*vx + vy*vy + vz*vz)
	if speed < 5 then
		return false
	end
	local ex,ey,ez = entity.get_origin(player)
	local lx,ly,lz = entity.get_origin(entity.get_local_player())
	local start_distance = math.abs(distance_3d(ex,ey,ez,lx,ly,lz))
	local smallest_distance = 999999
	for ticks = 1,ui.get(prediction_ticks) do

		local tex,tey,tez = extrapolate(player,ticks,ex,ey,ez)
		local distance = math.abs(distance_3d(tex,tey,tez,lx,ly,lz))

		if distance < smallest_distance then
			smallest_distance = distance
		end
		if smallest_distance < start_distance then
			return true
		end
	end
	--client.log(smallest_distance .. "      " .. start_distance)
	return smallest_distance < start_distance
end
local last_time_peeked = nil
local function is_local_peeking_enemy(player)
	local vx,vy,vz = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
	local speed = math.sqrt(vx*vx + vy*vy + vz*vz)
	if speed < 5 then
		return false
	end
	local ex,ey,ez = entity.get_origin(player)
	local lx,ly,lz = entity.get_origin(entity.get_local_player())
	local start_distance = math.abs(distance_3d(ex,ey,ez,lx,ly,lz))
	local smallest_distance = 999999
	for ticks = 1,ui.get(prediction_ticks) do

		local tex,tey,tez = extrapolate(entity.get_local_player(),ticks,lx,ly,lz)
		local distance = distance_3d(ex,ey,ez,tex,tey,tez)

		if distance < smallest_distance then
			smallest_distance = math.abs(distance)
		end
	if smallest_distance < start_distance then
			return true
		end
	end
	return smallest_distance < start_distance
end

local scrsize_x, scrsize_y = client.screen_size()
local center_x, center_y = scrsize_x / 2, scrsize_y / 2

local function on_paint(c)

	local state = ui.get(hotkey)
	ui.set_visible(ui_resetaa, state)
	ui.set_visible(ui_syncaa, state)
	ui.set_visible(chkbox_nervoswalk, state)
	ui.set_visible(hotkey_nervoswalk, state)
	ui.set_visible(slider_nervoswalk, state)
	ui.set_visible(ui_left_hotkey, state)
	ui.set_visible(ui_left_mode, state)
	ui.set_visible(ui_right_hotkey, state)
	ui.set_visible(ui_right_mode, state)
	ui.set_visible(ui_backwards_hotkey, state)
	ui.set_visible(ui_backwards_mode, state)
	ui.set_visible(ui_freestanding_hotkey, state)
	ui.set_visible(ui_indicator_combobox, state)
	ui.set_visible(ui_indicator_color_picker, state)

	state = (ui.get(ui_resetaa) == "Normal" or ui.get(ui_resetaa) == "Manual") and ui.get(hotkey)
	ui.set_visible(ui_backwards_hotkey, state)
	ui.set_visible(ui_backwards_mode, state)
	ui.set_visible(ui_indicator_color_picker, state)

	if not ui_get(hotkey) then return end


	local vel_x = ent_get_prop(ent_get_local(), "m_vecVelocity[0]")
	local vel_y = ent_get_prop(ent_get_local(), "m_vecVelocity[1]")
	local vel_z = ent_get_prop(ent_get_local(), "m_vecVelocity[2]")
	local vel = math.sqrt(vel_x * vel_x + vel_y * vel_y + vel_z * vel_z)

	local scrsize_x, scrsize_y = client_screensize()
	local center_x, center_y = scrsize_x / 2, scrsize_y / 2

	local indicator = ui_get(ui_indicator_combobox)
	local indicator_r, indicator_g, indicator_b, indicator_a = ui_get(ui_indicator_color_picker)

	if ui_get(ui_resetaa) == "Normal" then
		client_draw_text(ctx, center_x, center_y+40, 177, 151, 255, 255, nil, 0, "FAKE YAW")
	elseif ui_get(ui_resetaa) == "Ideal" then
		client_draw_text(ctx, center_x, center_y+40, 215, 114, 44, 255, nil, 0, "IDEAL YAW")
	elseif ui_get(ui_resetaa) == "Manual" then
		client_draw_text(ctx, center_x, center_y+40, 255, 0, 0, 255, nil, 0, "RESET YAW")
	end

	if ui_get(ui_syncaa) == "On" then
		client_draw_text(ctx, center_x, center_y+50, 209, 139, 230, 255, nil, 0, "DYNAMIC")
	elseif ui_get(ui_syncaa) == "Off" then
		client_draw_text(ctx, center_x, center_y+50, 255, 0, 0, 255, nil, 0, "DEFAULT")
	end
	if ui.get(ref_doubletap[1]) and ui.get(ref_doubletap[2]) then
		if is_dt() then
			client_draw_text(ctx, center_x, center_y+60, 10, 245, 5, 255, nil, 0, "DT")
		else
			client_draw_text(ctx, center_x, center_y+60, 245, 10, 5, 255, nil, 0, "DT")
		end
	end

	ui_set(on_shot_ref, not ui_get(duck_peek_ref))

	get_antiaim_dir()

	if ui_get(ui_resetaa) == "Normal" or ui_get(ui_resetaa) == "Manual" then

		if isFreestanding then
			setFreestanding()
			if indicator == "On" then
				client_draw_text(c, center_x, center_y + 45, 255, 255, 255, 255, "c+", 0, "V")
				client_draw_text(c, center_x + 45, center_y, 255, 255, 255, 255, "c+", 0, ">")
				client_draw_text(c, center_x - 45, center_y, 255, 255, 255, 255, "c+", 0, "<")
			end
		elseif isLeft then
			setLeft()
			if indicator == "On" then
				client_draw_text(c, center_x - 45, center_y, indicator_r, indicator_g, indicator_b, indicator_a, "c+", 0, "<")
				client_draw_text(c, center_x, center_y + 45, 255, 255, 255, 255, "c+", 0, "V")
				client_draw_text(c, center_x + 45, center_y, 255, 255, 255, 255, "c+", 0, ">")
			end
		elseif isRight then
			setRight()
			if indicator == "On" then
				client_draw_text(c, center_x + 45, center_y, indicator_r, indicator_g, indicator_b, indicator_a, "c+", 0, ">")
				client_draw_text(c, center_x, center_y + 45, 255, 255, 255, 255, "c+", 0, "V")
				client_draw_text(c, center_x - 45, center_y, 255, 255, 255, 255, "c+", 0, "<")
			end
		elseif isBack then
			setBack()
			if indicator == "On" then
				client_draw_text(c, center_x, center_y + 45, indicator_r, indicator_g, indicator_b, indicator_a, "c+", 0, "V")
				client_draw_text(c, center_x + 45, center_y, 255, 255, 255, 255, "c+", 0, ">")
				client_draw_text(c, center_x - 45, center_y, 255, 255, 255, 255, "c+", 0, "<")
			end
		end
	elseif ui_get(ui_resetaa) == "Ideal"  then
				if isFreestanding then
			setFreestanding()
			if indicator == "On" and not ui.get(lua_enabled) then
				client_draw_text(c, center_x + 45, center_y, 255, 255, 255, 255, "c+", 0, ">")
				client_draw_text(c, center_x - 45, center_y, 255, 255, 255, 255, "c+", 0, "<")
			end
		elseif isLeft then
			setLeft()
			if indicator == "On" and not ui.get(lua_enabled) then
				client_draw_text(c, center_x - 45, center_y, 215, 114, 44, 255, "c+", 0, "<")
				client_draw_text(c, center_x + 45, center_y, 255, 255, 255, 255, "c+", 0, ">")
			end
		elseif isRight then
			setRight()
			if indicator == "On" and not ui.get(lua_enabled) then
				client_draw_text(c, center_x + 45, center_y, 215, 114, 44, 255, "c+", 0, ">")
				client_draw_text(c, center_x - 45, center_y, 255, 255, 255, 255, "c+", 0, "<")
			end
		elseif isBack then
			setBack()
		end
	end
end


client_set_event_callback("run_command", function ()
	if not ui_get(chkbox_nervoswalk) then
		return
	end

	if not ui_get(hotkey_nervoswalk) then
		setSpeed(450)
	else
		setSpeed(ui_get(slider_nervoswalk))
	end
end)

local last_shot_time = {}
local inverter_enemy = {}
local old_inverter_enemy = {}
for i = 1 , 66 do
	last_shot_time[i] = 0
	inverter_enemy[i] = 1
	old_inverter_enemy[i] = 1
end
local best_player = -1
----- FAKE STANGA = 1         FAKE DREAPTA = 2
client.set_event_callback("bullet_impact", function(data)
   if not ui.get(lua_enabled) then return end
	local shooter = client.userid_to_entindex(data.userid)

	if (entity.is_enemy(shooter) == false) then
		return
	end

	local eye_pos = vector(client.eye_position())

	if (eye_pos:closest_ray_point(vector_c.eye_position(shooter), vector(data.x, data.y, data.z)):in_range(eye_pos, 250)) and (last_shot_time[shooter] == nil or globals_curtime() - last_shot_time[shooter] >= 0.05) then
		-- Shooter shot at our head.
		last_shot_time[shooter] = globals_curtime()
    if isRight then
			isLeft = true
			isRight = false
      old_inverter_enemy[shooter] = inverter_enemy[shooter]
      inverter_enemy[shooter] = 2
    elseif isLeft then
			isRight =  true
			isLeft = false
      old_inverter_enemy[shooter] = inverter_enemy[shooter]
      inverter_enemy[shooter] = 1

    end

  --  change_aa(shooter)
		best_player = shooter

	end
end)
local hitgroup_names = { "generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
client.set_event_callback("player_hurt", function(data)
  if not ui.get(lua_enabled) then return end
	local victim = client.userid_to_entindex(data.userid)
	local shooter = client.userid_to_entindex(data.attacker)

	if (shooter == entity.get_local_player() or victim == shooter or victim ~= entity.get_local_player() or not ui.get(lua_enabled)) then
		return
	end
	local hitbox_hit = hitgroup_names[data.hitgroup + 1]
	local old = inverter_enemy[shooter]
	if hitbox_hit ~= "left leg" and hitbox_hit ~= "right leg" and hitbox_hit ~= "head" then
		inverter_enemy[shooter] = old_inverter_enemy[shooter]
		if inverter_enemy[shooter] == 1 then
			isRight = true
			isLeft = false
		else
			isRight = false
			isLeft = true
		end
	end
	-- if inverter_enemy[shooter] ~= nil then
	-- 	client.log(hitbox_hit .. "   old: " .. old .. "   new: " .. inverter_enemy[shooter] )
	-- end
--	change_aa(shooter)
	best_player = shooter

end)
local current_inverter = 1
local current_old_inverter = 1
local function paint(ctx)
	if not ui.get(lua_enabled) then return end
  local closest_fov = 100000
  local needed_player = -1
	local player_list = entity.get_players(true)
	local x,y,z = client.eye_position()
	local eye_pos = Vector3(x,y,z)
  x,y,z = client.camera_angles()
	local cam_angles = Vector3(x,y,z)
	local is_local_alive = entity.is_alive(entity.get_local_player())
	if not is_local_alive then
		best_player = nil
	end
	if (player_list == nil or not is_local_alive)then return end
	for i = 1 , #player_list do
		local player = player_list[i]
		if not entity.is_dormant(player) and entity.is_alive(player) then
			if inverter_enemy[player] == nil then
				inverter_enemy[player] = 1
				old_inverter_enemy[player] = 1
			end
			local x1,y1,x2,y2 ,alpha = entity.get_bounding_box(player)
			if x1 == nil or y1 == nil or x2 == nil or y2 == nil then
				return
			end
			local txtsizex,txtsizey = renderer.measure_text("cb",inverter_enemy[player])
			-- renderer.text(x2 - (x2 - x1) * 0.5 ,y2 + txtsizey * 2.5 , 255,0,0, alpha * 255, "cb",400,"TYPE " .. inverter_enemy[player]) annoying render thing
			if(is_enemy_peeking(player) or is_local_peeking_enemy(player) or not ui.get(on_peek)) then
				last_time_peeked = globals_curtime()
				local enemy_head_pos = Vector3(entity.hitbox_position(player,0))
				local current_fov = get_FOV(cam_angles,eye_pos, enemy_head_pos)
			--	client.log(current_fov)
				if current_fov < closest_fov then
					closest_fov = current_fov
					needed_player = player
				end
			end
		end

	end
	if best_player ~= nil and entity.is_alive(best_player) and entity.is_enemy(best_player) and not entity.is_dormant(best_player) then
		needed_player = best_player
	else
		best_player = nil
	end
	if needed_player ~= -1 and is_local_alive then
		local x1,y1,x2,y2 ,alpha = entity.get_bounding_box(needed_player)
		if x1 == nil or y1 == nil or x2 == nil or y2 == nil then
			return
		end
		current_inverter = inverter_enemy[needed_player]
		current_old_inverter = old_inverter_enemy[needed_player]
		local txtsizex,txtsizey = renderer.measure_text("cb",inverter_enemy[needed_player])
		--renderer.text(x2 - (x2 - x1) * 0.5 ,y2 + txtsizey * 2.5 , 50,205,50, alpha * 255, "cb",400,"TYPE " .. inverter_enemy[needed_player]) another annoying render thing
		--change_aa(needed_player)
		if current_inverter == 1 then
			isRight = true
			isLeft = false

		else
			isRight = false
			isLeft = true
		end
		local color_left = inverter_enemy[needed_player] == 1 or inverter_enemy[needed_player] == 3
		local color_right = not color_left

		if color_right then
			client.draw_text(c, center_x - 45, center_y, 255,255,255,255, "c+", 0, "<")
			client.draw_text(c, center_x + 45, center_y, 255,55,20,255, "c+", 0, ">")
		else
			client.draw_text(c, center_x - 45, center_y,255,55,20,255, "c+", 0, "<")
			client.draw_text(c, center_x + 45, center_y, 255,255,255,255, "c+", 0, ">")
		end
	else
		isRight,isLeft = false
		
		ui_set(yaw_val_reference, 0)
		ui_set(reference_fake, "Jitter")
		ui_set(reference_fake_slider, 95)
		ui_set(yaw_jitter_reference, "offset")
		ui_set(yaw_jitter_val_reference, 0)

	end

end
-- error handling
client.set_event_callback("paint", paint)
client.set_event_callback("paint", function(data)


end)

local err = client_set_event_callback('paint', on_paint)

-- log error to console
if err then
	client_log('set_event_callback failed: ', err)
end
