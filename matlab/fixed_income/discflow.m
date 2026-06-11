 
function discPr=discflow(param,coup,face,istart,iend,istep)
% This function uses function NSS.m
  discPr = 0;
   for ii = istart:istep:iend
    discspot=NSS(param,ii);
    cf = coup * exp(-discspot / 100 * ii);
    discPr = discPr + cf;
   end  
  discPr = discPr + ...
       face * exp(-discspot / 100 * (istart + iend - 1)) ...
       - coup * (1 - istart);
 end

