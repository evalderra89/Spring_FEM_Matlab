%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: This code finds the displacements, forces and nodal forces for a
%          spring, using the finite element method.
% Written By: Esteban Valderrama, 11/25/2015
%             University of Wisconsin at Platteville
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
clc

%%  Read Input file
file = 'problem3.txt';
[nodes, elems, nelems, F, stiffness, n_stiffness, u, ind_u, ind_F] = readFiles(file);

%% Create Element and Global Stiffness Matrices
[K, Ke] = stiffnessMatrix(stiffness, n_stiffness, elems, nelems, nodes);

%%  Solve for Displacements
fixed = ind_u;
free = setdiff([1:nodes]',[fixed]);
u(free) = K(free,free)\F(free);

%%  Solve for Force
F = K * u;

%%  Solve for node forces
% Solve for f when the problem with different K
if n_stiffness == 1
    for i = 1:nelems
        dof = elems(i,:);      % Select the element
        f(i,:) = Ke(:,:,1) * u(dof,1); % Solve for f
        show_f(i,:) = [i f(i,:)];     % Accumulate results
    end
else
    % Solve for f when the problem with the same K
    for i = 1:nelems
        for j = 1:n_stiffness
            dof = elems(i,:);      % Select the element
            f(i,:) = Ke(:,:,j) * u(dof,1); % Solve for f
            show_f(i,:) = [i f(i,:)];     % Accumulate results
        end
    end
end
%%  Display results
disp('Local Stiffness Matrix:')
if n_stiffness == 1
    for i = 1:nelems
        fprintf('Element: %d\n', i)
        disp(Ke(:,:,1))
    end
else
    % Solve for f when the problem with the same K
    for i = 1:nelems
        fprintf('Element: %d\n', i)
        disp(Ke(:,:,i))
    end
end
disp('Global Stiffness Matrix:')
disp(K)
disp('Displacements:')
n = 1:nodes; format
disp([n' u])
disp('Reactions:')
disp([fixed F(fixed)])
disp('Element Forces:')
disp(show_f)