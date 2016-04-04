function [Phi,Theta,Psi,Rot_mat] = SN_RotateToZAxis(vector)
% [PHI, THETA, PSI] = SN_ROTATETOZAXIS(VECTOR) figures out PHI (x-Euler
% angle), THETA (y-Euler angle), Psi (z-Euler angle) that would take to
% transform the vector to [0 0 lengthof(vector)]
% The transform is to be used with the rotation matrix found at http://en.wikipedia.org/wiki/Rotation_matrix
% 
% [..., ROT_MAT] = SN_ROTATETOZAXIS(VECTOR) provides a rotation matrix for
% use as well;
%
% written by San Nguyen 2012 10

% The orthogonal matrix (post-multiplying a column vector) corresponding to a clockwise/left-handed rotation
% http://en.wikipedia.org/wiki/Rotation_matrix
Rot_mat = @(p,t,s)[ cos(t)*cos(s), -cos(p)*sin(s) + sin(p)*sin(t)*cos(s),  sin(p)*sin(s) + cos(p)*sin(t)*cos(s);
                    cos(t)*sin(s),  cos(p)*cos(s) + sin(p)*sin(t)*sin(s), -sin(p)*cos(s) + cos(p)*sin(t)*sin(s);
                   -sin(t),         sin(p)*cos(t),                         cos(p)*cos(t)];
Psi = 0;
               
if length(vector) ~= 3
    error('MATLAB:SN_RotateToZAxis:wrongInput','Vector must be length of 3');
end
if isrow(vector)
    vector = vector';
end

yz_vec = vector([2,3]);
r = sqrt(sum(yz_vec.^2));
Phi = acos(sum(yz_vec.*([0; 1;]))/r);

if vector(2) < 0
    Phi = pi-Phi;
end

vector2 = Rot_mat(Phi,0,0)*vector;

xz_vec = vector2([1,3]);

r = sqrt(sum(xz_vec.^2));
Theta = acos(sum(xz_vec.*([0; 1;]))/r);

if vector2(1) > 0
    Theta = -Theta;
end

% if vector(3)
%     Theta = pi + Theta;
% end

Rot_mat = Rot_mat(Phi,Theta,Psi);

return;
end