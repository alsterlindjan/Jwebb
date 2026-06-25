function ff = solve_phi_gen(fy,vec,phi,dim,rot_i,rot_j)
%% SOLVE_PHI_GEN  Construct restriction equations for Givens-rotated factors
%
%   FF = SOLVE_PHI_GEN(fy, vec, phi, dim, rot_i, rot_j) builds the system of
%   nonlinear equations required to impose identification restrictions on
%   factor loadings using a sequence of Givens rotations. The restrictions
%   ensure that the first rotated factor corresponds to the short-term
%   interest rate.
%
%   Inputs:
%       fy     : Vector of free rotation angles to be solved for
%       vec    : First-row PCA loadings (used to impose identification)
%       phi    : Fixed final rotation angle (typically set to zero)
%       dim    : Dimension of the Givens rotation matrices
%       rot_i  : Row indices defining each Givens rotation plane
%       rot_j  : Column indices defining each Givens rotation plane
%
%   Output:
%       ff     : (dim-1)-by-1 vector of restriction equations. A root of ff
%                corresponds to a set of rotation angles satisfying the
%                identification conditions.
%
%   Notes:
%       - The function applies a sequence of Givens rotations:
%             S = G_1 * G_2 * ... * G_dim
%       - Each Givens matrix is constructed using GIVENS_ROTATION.m
%       - The restrictions enforce that all but the first element of the
%         rotated first loading vector are zero.
%
% _Jan Alsterlind 2025_
 
 angle=[fy phi];
 Smat=eye(dim);

  for jj=1:dim
    G = givens_rotation(angle(jj), dim, rot_i(jj), rot_j(jj));
    Smat = Smat*G;
  end

  ff = zeros(dim-1,1);
  for kk = 1:dim-1 
    ff(kk,:) =Smat(kk+1,:)*vec(1,:)';
  end 
end

