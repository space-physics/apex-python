      program test
c Test program for apex.f90 module
      use apex
      implicit none
      integer ier,i,iyr,iday,ihr,imn
      real date,glat,glon,alt,hr,altmax, gdlat,gdlon,qdlon
      real gclat,gclon,gmlat,gmlon
      real bmag,si,alon,malat,vmp,W,D,Be3,sim,qdlat,F
      real B(3),bhat(3),d1(3),d2(3),d3(3),e1(3),e2(3),e3(3),f1(3),f2(3)
     + ,f3(3),g1(3),g2(3),g3(3)
      real vx,vy,vz,ve1,ve2,ve3,Ed1,Ed2
      real sec,sbsllat,sbsllon,csza,sza,mlt 
c
c Set up 3D interpolation arrays for date=2015.1, between the ground
c  and at least altmax=1000 km altitude.
      date = 2015.1
      altmax = 1000.
      write (6,'(''date='',f7.2,''        altmax='',f10.1)') date,altmax
      call apex_setup(date,altmax)
      write (6,'(''nglat='',i5,''    nglon='',i5,''    ngalt='',i5)')
     +  nglat,nglon,ngalt
c
c Example 1: Calculate Apex parameters for an arbitrary location. Use a
c  reference height hr=80 km.
      write (6,'(''Example 1:  Calculate Apex parameters for an arbitrar
     +y location.'',/,''    Use a reference height hr=80 km.'')')
      glat = 40.
      glon = -105.
      alt = 800.
      hr = 80.
      call apex_mall(glat,glon,alt,hr, B,bhat,bmag,si,alon,malat,vmp,W,
     +  D,Be3,sim,d1,d2,d3,e1,e2,e3,qdlat,F,f1,f2,f3,g1,g2,g3,ier)
      write (6,'(a8,f10.4)') 'hr    = ',hr
      write (6,'(a8,f10.4)') 'glat  = ',glat
      write (6,'(a8,f10.4)') 'glon  = ',glon
      write (6,'(a8,f10.4)') 'alt   = ',alt
      write (6,'(a11,f10.4)') 'm(110)lat =',malat
      write (6,'(a8,f10.4)') 'qdlat = ',qdlat
      write (6,'(a21,f10.4)') 'm(110)lon and qdlon =',alon
c
c Example 2: Calculate the scaled ion velocity components ve1,ve1,ve3
c  and the scaled electric-field components Ed1,Ed2 (assuming
c  E = -v x B) for three cases of a 100 m/s velocity: purely eastward
c  (geographic), purely northward, and purely upward, all for this
c  location.  Note that ve1,ve2,ve3,Ed1,Ed2 are by definition constant
c  along the entire geomagnetic-field line.
      write    (6,'(1x,/,''Example 2:  Calculate scaled velocities and e
     +lectric-field components'',/,''    for three cases at this locatio
     +n.'')')
      vx = 100.
      vy = 0.
      vz = 0.
      ve1 = d1(1)*vx + d1(2)*vy + d1(3)*vz
      ve2 = d2(1)*vx + d2(2)*vy + d2(3)*vz
      ve3 = d3(1)*vx + d3(2)*vy + d3(3)*vz
      Ed1 = -ve2/Be3
      Ed2 =  ve1/Be3
      write (6,'(a43,3f7.2)') 'Case 1. Purely eastward velocity, vx,vy,v
     1z=',vx,vy,vz
      write (6,'(a12,3f8.2,a12,2f9.5)') 've1,ve2,ve3=',ve1,ve2,ve3,
     1'    Ed1,Ed2=',Ed1,Ed2 
      vx = 0.
      vy = 100.
      vz = 0.
      ve1 = d1(1)*vx + d1(2)*vy + d1(3)*vz
      ve2 = d2(1)*vx + d2(2)*vy + d2(3)*vz
      ve3 = d3(1)*vx + d3(2)*vy + d3(3)*vz
      Ed1 = -ve2/Be3
      Ed2 =  ve1/Be3 
      write (6,'(a44,3f7.2)') 'Case 2. Purely northward velocity, vx,vy,
     1vz=',vx,vy,vz
      write (6,'(a12,3f8.2,a12,2f9.5)') 've1,ve2,ve3=',ve1,ve2,ve3,
     1'    Ed1,Ed2=',Ed1,Ed2 
      vx = 0.
      vy = 0.
      vz = 100.
      ve1 = d1(1)*vx + d1(2)*vy + d1(3)*vz
      ve2 = d2(1)*vx + d2(2)*vy + d2(3)*vz
      ve3 = d3(1)*vx + d3(2)*vy + d3(3)*vz
      Ed1 = -ve2/Be3
      Ed2 =  ve1/Be3
      write (6,'(a41,3f7.2)') 'Case 3. Purely upward velocity, vx,vy,vz=
     1',vx,vy,vz
      write (6,'(a12,3f8.2,a12,2f9.5)') 've1,ve2,ve3=',ve1,ve2,ve3,
     1'    Ed1,Ed2=',Ed1,Ed2 
c
c Example 3: Calculate the geographic latitude and longitude of the
c  footpoints of this field line at 110 km in both hemispheres. 
      write (6,'(1x,/,''Example 3:  Calculate the geographic latitude an
     +d longitude of the footpoints'',/,''    of this field line at 110 
     +km in both hemispheres.'')') 
      alt = 110.
      call apex_m2g(malat,alon,alt,hr,gdlat,gdlon)
      write (6,'(a13,f10.4)') '110 km glat =',gdlat
      write (6,'(a13,f10.4)') '110 km glon =',gdlon
      call apex_m2g(-malat,alon,alt,hr,gdlat,gdlon)
      write (6,'(a23,f10.4)') 'opp. hem. 110 km glat =',gdlat
      write (6,'(a23,f10.4)') 'opp. hem. 110 km glon =',gdlon
c
c Example 4:  Use apex_q2g to determine geographic coordinates from
c  given quasi-dipole coordinates.
      write (6,'(1x,/,''Example 4:  Use apex_q2g to get geographic coord
     +inates from given quasi-dipole'',/,''     coordinates, then revers
     +e the calculation by calling apex_mall'')')
      qdlat = 45.
      qdlon = 2.
      alt   = 110.
      write (6,'(''Choose quasi-dipole coordinates:           qdlat,qdlo
     +n,alt='',3f7.2)') qdlat,qdlon,alt
      call apex_q2g(qdlat,qdlon,alt,gdlat,gdlon,ier)
      if (ier /= 0) then
        write(6,"('>>> apex_q2g error ')")
        stop 'apex_q2g'
      endif
      write (6,'(''apex_q2g returns geographic coordinates:   gdlat,gdlo
     +n    ='',2f7.2)') gdlat,gdlon

c Use the calculated geographic coordinates to recompute the
c  quasi-dipole coordinates, for comparison with the original input:
      call apex_mall(gdlat,gdlon,alt,hr, B,bhat,bmag,si,qdlon,malat,vmp,
     1  W,D,Be3,sim,d1,d2,d3,e1,e2,e3,qdlat,F,f1,f2,f3,g1,g2,g3,ier)
      write (6,'(''For input gdlat,gdlon,alt apex_mall returns: qdlat,qd
     +lon,alt='',3f7.2)') qdlat,qdlon,alt

c Example 5:  Test related routines subsol, cossza, magloctm, mlt2alon.
c  Ensure that IGRF coefficients are set up for the correct date
c  (since cofrm may have been called by apex_mka for a different date).
      write (6,'(1x,/,''Example 5: Use related routines subsol, magloctm
     + and mlt2alon to obtain the'',/,''     subsolar point, use it to g
     +et magnetic local time and solar zenith angle, '',/,''     then co
     +nvert magnetic local time back to apex longitude'')')
      date = 2018.5
      call cofrm(date)
      write (6,'(''Call cofrm for date ='',f10.1,/,
     +''Dipole pole colatitude, east longitude, and magnetic potential a
     +re:'',/,
     +''colat,elon,vp='',3f9.4,'' deg, deg, T-m'')') date,colat,elon,vp

c Find subsolar latitude, longitude for a specific time:
      iyr  = 2018
      iday = 182
      ihr  = 12
      imn  = 0
      sec  = 0.
      write (6,'(''subsol inputs: iyr,iday,ihr,imn,sec='',4i5,f5.0,'' UT
     +'')') iyr,iday,ihr,imn,sec
      call subsol(iyr,iday,ihr,imn,sec,sbsllat,sbsllon)
      write (6,'(''subsol returns: sbsllat,sbsllon ='',2F8.2,'' deg'')')
     +                             sbsllat,sbsllon

c Find solar zenith angle at glat,glon for this time:
      call cossza(glat,glon,sbsllat,sbsllon,csza)
      sza = acos(csza)*rtd
      write (6,'(''Then at glat,glon='',2f8.2,/,''cossza gives solar zen
     +ith angle ='',f8.2,'' degrees'')') glat,glon,sza

c Find magnetic local time
      call apex_mall(glat,glon,alt,hr, B,bhat,bmag,si,qdlon,malat,vmp,
     1  W,D,Be3,sim,d1,d2,d3,e1,e2,e3,qdlat,F,f1,f2,f3,g1,g2,g3,ier)
      write (6,'(''apex_mall gives magnetic longitude ='',f8.2)') qdlon 
      call magloctm(qdlon,sbsllat,sbsllon,colat,elon,mlt)
      write (6,'(''magloctm returns: mlt ='',f7.3,'' hours'')') mlt

c Find magnetic (modified apex and quasi-dipole) longitude 
      call mlt2alon(mlt,sbsllat,sbsllon,colat,elon,alon)
      write (6,'(''mlt2alon returns magnetic longitude ='',f7.2,'' deg''
     +)') alon

c Find dipole gmlat,gmlon corresponding to geographic glat,glon:
      call gc2gm(glat,glon,gmlat,gmlon) 
      write (6,'(''gc2gm returns: gmlat,gmlon ='',2F8.2,'' deg'')')
     +                            gmlat,gmlon 
      call gm2gc(gmlat,gmlon,gclat,gclon) 
      write (6,'(''gm2gc returns: gclat,gclon ='',2F8.2,'' deg'')')
     +                            gclat,gclon 

      end

