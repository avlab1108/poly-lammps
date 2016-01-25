


BEGIN{strt=0;}
{
    if(strt == 1)
    {
        if(NR%1==0)
        {
            if($2 == 1)
            {
                print $4," ",$5," ",$6," ",$2," 0 0 0" ;
            }
            else
            {
                print $4," ",$5," ",$6," "-10" 0 0 0" ;
            }
        }
    }
}

{
    if(index($0, "ITEM: ATOMS id type mass x y z") != 0)
    {
        strt = 1 ;
        
    }
}
