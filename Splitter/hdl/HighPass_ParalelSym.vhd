----------------------------------------------------------------------------
-- high pass block calculating in parallel 
-- and taking advantage of the symetrical nature of the filter 
----------------------------------------------------------------------------
ARCHITECTURE ParalelSym OF HighPass IS
    
    -- constants 
    constant HALF_FILTER_TAP_NB: positive := FILTER_TAP_NB/2 + 
    (FILTER_TAP_NB mod 2);
    constant FINAL_SHIFT : positive := requiredBitNb(FILTER_TAP_NB);
    constant ACCUMULATOR_Bit_NB: positive := COEFF_BIT_NB + audioIn'length +
    FINAL_SHIFT ;    
    constant ShiftNB : positive := ACCUMULATOR_Bit_NB-HighpassOut'length-7;    
    -- arrays 
    type        t_samples is array (0 to FILTER_TAP_NB-1) 
    of signed (audioIn'range);  -- vector of FILTER_TAP_NB signed elements
    signal      samples : t_samples ; 
    type coefficients is array (0 to HALF_FILTER_TAP_NB-1) 
    of signed( COEFF_BIT_NB-1 downto 0);
    signal coeff: coefficients :=( 
    x"FFFFCB50", x"FFFF2E0D", x"FFFE359A", x"FFFCEF56", x"FFFB848F", 
    x"FFFA3D35", x"FFF97CD0", x"FFF9B84E", x"FFFB6471", x"FFFEDDF1", 
    x"00044DFB", x"000B8F3A", x"00141880", x"001CF2D1", x"0024BFB5",
    x"0029D37C", x"002A6461", x"0024CC4C", x"0017D745", x"0003152D", 
    x"FFE72295", x"FFC5DB4B", x"FFA2698D", x"FF812786", x"FF674D57",
    x"FF5A6C46", x"FF5FBF22", x"FF7B5F75", x"FFAF7589", x"FFFB7DF0", 
    x"005BC07B", x"00C91294", x"0138F8C5", x"019E320A", x"01E9AB58", 
    x"020BCCB4", x"01F60471", x"019C6A62", x"00F74E19", x"0004814B", 
    x"FEC83324", x"FD4D3AC1", x"FBA4BD09", x"F9E52B90", x"F828ACE2", 
    x"F68B107B", x"F5277F16", x"F41621A5", x"F369FC2F", x"732F35C3");
begin 

 
    shiftSamples : process(clock,reset)
    begin
        if (reset = '1') then
            samples <= (others =>(others => '0'));
        elsif rising_edge(clock) then  
        
            if en = '1' then
                -- shifting the registers 
                -- the first info goes to samples 0
                samples(0) <= audioMono ;
                -- loop to shift the samples 
                shift : for ii in 0 to FILTER_TAP_NB-2 loop
                  samples(ii+1) <= samples(ii) ;
                end loop shift;
            end if;
            
        end if; 
    end process shiftSamples;
 
    multiplyAdd : process(samples)
        variable accumulator : signed (ACCUMULATOR_Bit_NB-1 DOWNTO 0);
    begin 
        accumulator := (others => '0');
        -- each sample is added with it's counterpart 
        --(0 with n , 1 with n-1 .... ect). Then multiplied 
        --with the corresponding coeff and then added to the accumulator
        multAdd : for ii in 0 to HALF_FILTER_TAP_NB-1 loop
            if ii = HALF_FILTER_TAP_NB-1 and (FILTER_TAP_NB mod 2)= 1  then 
                accumulator := accumulator + samples(ii) * coeff(ii);   
            else
                accumulator := accumulator+(resize(samples(ii),audioIn'length+1)
                +samples(FILTER_TAP_NB-1-ii))*coeff(ii);
            end if;   
        end loop multAdd;
        -- updating the output      
        HighpassOut <= resize(shift_righ(accumulator,
        ACCUMULATOR_Bit_NB-HighpassOut'length-8),HighpassOut'length);
     
    end process multiplyAdd;
END ARCHITECTURE ParalelSym;

