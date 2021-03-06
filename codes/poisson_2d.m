% ----------------------------------------------------------------------- %
%                                     __  __  __       _  __   __         %
%        |\/|  _  |_ |  _  |_   |__| /   |_  |  \  _  (_ |__) |_          %
%        |  | (_| |_ | (_| |_)     | \__ |   |__/ (_) |  | \  |           %
%                                                                         %
% ----------------------------------------------------------------------- %
%                                                                         %
%   Author: Alberto Cuoci <alberto.cuoci@polimi.it>                       %
%   CRECK Modeling Group <http://creckmodeling.chem.polimi.it>            %
%   Department of Chemistry, Materials and Chemical Engineering           %
%   Politecnico di Milano                                                 %
%   P.zza Leonardo da Vinci 32, 20133 Milano                              %
%                                                                         %
% ----------------------------------------------------------------------- %
%                                                                         %
%   This file is part of Matlab4CFDofRF framework.                        %
%                                                                         %
%	License                                                               %
%                                                                         %
%   Copyright(C) 2017 Alberto Cuoci                                       %
%   Matlab4CFDofRF is free software: you can redistribute it and/or       %
%   modify it under the terms of the GNU General Public License as        %
%   published by the Free Software Foundation, either version 3 of the    %
%   License, or (at your option) any later version.                       %
%                                                                         %
%   Matlab4CFDofRF is distributed in the hope that it will be useful,     %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of        %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         %
%   GNU General Public License for more details.                          %
%                                                                         %
%   You should have received a copy of the GNU General Public License     %
%   along with Matlab4CRE. If not, see <http://www.gnu.org/licenses/>.    %
%                                                                         %
%-------------------------------------------------------------------------%
%                                                                         %
%  Code: 2D Poisson equation using Gauss-Siedler method coupled to SOR    %
%        The code is adapted and extended from Tryggvason, Computational  %
%        Fluid Dynamics http://www.nd.edu/~gtryggva/CFD-Course/           %
%                                                                         %
% ----------------------------------------------------------------------- %
close all;
clear variables;

nx=39;                  % number of grid points along x
ny=39;                  % number of grid points along y
max_iterations=5000;    % max number of iterations
lengthx=2.0;            % domain length along x [m]
lengthy=2.0;            % domain length along y [m]
hx=lengthx/(nx-1);      % grid step along x [m]
hy=lengthy/(ny-1);      % grid step along y [m] 
beta=1.;                % SOR coefficient

% Memory allocation
T=zeros(nx,ny);
S=zeros(nx,ny);

% Grid axes
xaxis = 0:hx:lengthx;
yaxis = 0:hy:lengthy;

% Boundary conditions (west side)
T(1, ny*1/3:ny*2/3) = 1;

% Iterations
for l=1:max_iterations
    
    for i=2:nx-1
        for j=2:ny-1
            T(i,j)= beta*(hx^2*hy^2/2/(hx^2+hy^2))*...
                    ( (T(i+1,j)+T(i-1,j))/hx^2+(T(i,j+1)+T(i,j-1))/hy^2 ...
                      -S(i,j) )+ ...
                    (1.0-beta)*T(i,j);
        end
    end
    
    % Residual
    res=0;
    for i=2:nx-1
        for j=2:ny-1
            res=res+abs( (T(i+1,j)-2*T(i,j)+T(i-1,j))/hx^2 + ...
                         (T(i,j+1)-2*T(i,j)+T(i,j-1))/hy^2 - S(i,j) );
        end
    end
    
    tot_res = res/((nx-2)*(ny-2));
    fprintf('Iteration: %d - Residual: %e\n', l, tot_res);
    
    if (tot_res < 0.001)
        break;
    end
end
contour(xaxis, yaxis, T');
