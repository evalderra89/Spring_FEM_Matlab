%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: This function created the global stiffness matrix.
% Written By: Esteban Valderrama, 11/25/2015
%             University of Wisconsin at Platteville
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [K, Ke] = stiffnessMatrix(stiffness, n_stiffness, elems, nelems, nodes)

% Create Element Stiffness Matrix
if n_stiffness == 1;
    Ke = zeros(2,2);
    Ke = [stiffness -stiffness;-stiffness stiffness];
else
    Ke = zeros(2,2,n_stiffness);
    for i = 1:n_stiffness
        Ke(:,:,i) = [stiffness(i,2) -stiffness(i,2);-stiffness(i,2) stiffness(i,2)];
    end
    if n_stiffness ~= nelems
        disp('Each element needs a stiffness value.')
        exit(0)
    end
end

%  Create Stiffness Matrix
K = zeros(nodes,nodes);

% Create global stiffness matrix for a problem with different K
if n_stiffness == 1
    for i = 1:nelems
        dof = elems(i,:);            % Select the element
        K(dof,dof) = K(dof,dof) + Ke(:,:,1); % Fill K
    end
else
    % Create global stiffness matrix for a problem with the same K
    for i = 1:nelems
        for j = 1:n_stiffness
            dof = elems(i,:);            % Select the element
            K(dof,dof) = K(dof,dof) + Ke(:,:,j); % Fill K
        end
    end
end