function [y v C]=estimate_y_and_v_ivector(S, m, E, d, v, u, z, y, x, spk_ids)

S1=load('data/stats/1.mat');
F=S1.Fi';
N=S1.Ni';
dim = size(F,2)/size(N,2);
index_map = reshape(repmat(1:size(N,2), dim,1),size(F,2),1);
y = zeros(max(spk_ids), size(v,1));

if nargout > 1
  for c=1:size(N,2)
    A{c} = zeros(size(v,1));
  end
  C = zeros(size(v,1), size(F,2));
end

for c=1:size(N,2)
  c_elements = ((c-1)*dim+1):(c*dim);
  vEvT{c} = v(:,c_elements) .* repmat(1./E(c_elements), size(v, 1), 1) * v(:,c_elements)';
end
% unique(spk_ids)

for ii = unique(spk_ids)'
  speakers_sessions = find(spk_ids == ii);
  Si=load(['data/stats/',num2str(ii),'.mat']);
  
  %Fs = sum(F(speakers_sessions,:), 1);
  Fs = Si.Fi'; 
  
  %Nss = sum(N(speakers_sessions,:), 1);
  Nss = Si.Ni'; 
  N= Si.Ni'; 
  
  Ns = Nss(1,index_map);
  Fs = Fs -  (m + z(ii,:) .* d) .* Ns;
  for jj = speakers_sessions'
    %Fs = Fs - (x(jj,:) * u) .* N(jj, index_map);
    Fs = Fs - (x(jj,:) * u) .* N(1, index_map);
  end

% L = eye(size(v,1)) + v * diag(Ns./E) * v';
  L = eye(size(v,1));
  for c=1:size(N,2)
    L = L + vEvT{c} * Nss(c);
  end

  invL = inv(L);
  y(ii,:) = ((Fs ./ E) * v') * invL;
  if nargout > 1
    invL = invL + y(ii,:)' * y(ii,:);
    for c=1:size(N,2)
      A{c} = A{c} + invL * Nss(c);
    end
    C = C + y(ii,:)' * Fs;
  end
end  
% 
if nargout == 3
 % output new estimates of y and accumulators A and C
 v = A;
elseif nargout == 2
 % output new estimates of y and v
 v=update_v(A, C);
end

%-------------------------------------------------
function C=update_v(A, C)
dim = size(C,2)/length(A);
for c=1:length(A)
  c_elements = ((c-1)*dim+1):(c*dim);
  C(:,c_elements) = inv(A{c}) * C(:,c_elements);
end
 min(min(abs(inv(A{c}))))
%  