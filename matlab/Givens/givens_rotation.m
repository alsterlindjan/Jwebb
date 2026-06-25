function GR = givens_rotation(theta, dim, i, j)
%% GIVENS_ROTATION  Construct a Givens rotation matrix
%
%   GR = GIVENS_ROTATION(theta, dim, i, j) returns a dim-by-dim Givens
%   rotation matrix GR corresponding to a rotation by angle theta (radians)
%   in the plane spanned by axes i and j.
%
%   Inputs:
%       theta : Rotation angle in radians
%       dim   : Dimension of the square matrix
%       i, j  : Indices defining the rotation plane (1-based)
%
%   Output:
%       GR    : Orthogonal Givens rotation matrix in R^dim
%
%   Note:
%       The Givens submatrix is defined as:
%           [  c   s
%             -s   c ]
%
% _Jan Alsterlind 2025_

    c = cos(theta);
    s = sin(theta);
    GR = eye(dim);
    GR([i j],[i j]) = [c s; -s c];
end
