function [M, Mx, My] = diffusionTermCylindrical2D(D)
% This function uses the central difference scheme to discretize a 2D
% diffusion term in the form \grad . (D \grad \phi) where u is a face vactor
% It also returns the x and y parts of the matrix of coefficient.
%
% SYNOPSIS:
%
%
% PARAMETERS:
%
%
% RETURNS:
%
%
% EXAMPLE:
%
% SEE ALSO:
%

% Copyright (c) 2012-2016 Ali Akbar Eftekhari
% See the license file

% extract data from the mesh structure
Nr = D.domain.dims(1);
Nz = D.domain.dims(2);
G=reshape(1:(Nr+2)*(Nz+2), Nr+2, Nz+2);
DR = repmat(D.domain.cellsize.x, 1, Nz);
DZ = repmat(D.domain.cellsize.y', Nr, 1);
dr = 0.5*(DR(1:end-1,:)+DR(2:end,:));
dz = 0.5*(DZ(:,1:end-1)+DZ(:,2:end));
rp = repmat(D.domain.cellcenters.x, 1, Nz);
rf = repmat(D.domain.facecenters.x, 1, Nz);

% define the vectors to store the sparse matrix data
iix = zeros(3*(Nr+2)*(Nz+2),1);	iiy = zeros(3*(Nr+2)*(Nz+2),1);
jjx = zeros(3*(Nr+2)*(Nz+2),1);	jjy = zeros(3*(Nr+2)*(Nz+2),1);
sx = zeros(3*(Nr+2)*(Nz+2),1);	sy = zeros(3*(Nr+2)*(Nz+2),1);
mnx = Nr*Nz;	mny = Nr*Nz;

% reassign the east, west, north, and south velocity vectors for the
% code readability
De = rf(2:Nr+1,:).*D.xvalue(2:Nr+1,:)./(rp.*dr(2:Nr+1,:).*DR(2:Nr+1,:));
Dw = rf(1:Nr,:).*D.xvalue(1:Nr,:)./(rp.*dr(1:Nr,:).*DR(2:Nr+1,:));
Dn = D.yvalue(:,2:Nz+1)./(dz(:,2:Nz+1).*DZ(:,2:Nz+1));
Ds = D.yvalue(:,1:Nz)./(dz(:,1:Nz).*DZ(:,2:Nz+1));

% calculate the coefficients for the internal cells
AE = reshape(De,mnx,1);
AW = reshape(Dw,mnx,1);
AN = reshape(Dn,mny,1);
AS = reshape(Ds,mny,1);
APx = reshape(-(De+Dw),mnx,1);
APy = reshape(-(Dn+Ds),mny,1);

% build the sparse matrix based on the numbering system
rowx_index = reshape(G(2:Nr+1,2:Nz+1),mnx,1); % main diagonal x
iix(1:3*mnx) = repmat(rowx_index,3,1);
rowy_index = reshape(G(2:Nr+1,2:Nz+1),mny,1); % main diagonal y
iiy(1:3*mny) = repmat(rowy_index,3,1);
jjx(1:3*mnx) = [reshape(G(1:Nr,2:Nz+1),mnx,1); reshape(G(2:Nr+1,2:Nz+1),mnx,1); reshape(G(3:Nr+2,2:Nz+1),mnx,1)];
jjy(1:3*mny) = [reshape(G(2:Nr+1,1:Nz),mny,1); reshape(G(2:Nr+1,2:Nz+1),mny,1); reshape(G(2:Nr+1,3:Nz+2),mny,1)];
sx(1:3*mnx) = [AW; APx; AE];
sy(1:3*mny) = [AS; APy; AN];

% build the sparse matrix
kx = 3*mnx;
ky = 3*mny;
Mx = sparse(iix(1:kx), jjx(1:kx), sx(1:kx), (Nr+2)*(Nz+2), (Nr+2)*(Nz+2));
My = sparse(iiy(1:ky), jjy(1:ky), sy(1:ky), (Nr+2)*(Nz+2), (Nr+2)*(Nz+2));
M = Mx + My;
