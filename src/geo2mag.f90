program geo2mag

use, intrinsic :: iso_fortran_env, only: real64
use apex, only : apex_setup,gc2gm

implicit none (type, external)

integer :: i, N = 1000000
character(8) :: buf
real :: glat, glon, gmlat, gmlon, yeardec, r
real(real64) :: tic, toc

call get_command_argument(1, buf, status=i)
if(i/=0) error stop 'missing longitude (degrees)'
read(buf, '(f8.3)') glat

call get_command_argument(2, buf, status=i)
if(i/=0) error stop 'missing longitude (degrees)'
read(buf, '(f8.3)') glon

call get_command_argument(3, buf, status=i)
if(i/=0) error stop 'missing decimal year e.g. 2020.35'
read(buf, '(f8.4)') yeardec

print *, "geographic input lat, lon (degrees), year", glat, glon, yeardec

! -------------------------
call cpu_time(tic)
call apex_setup(yeardec,altmax=1000.)
call cpu_time(toc)
print *, toc-tic, ' seconds to setup Apex'

! -- benchmark
call cpu_time(tic)
do i = 1,N
  call random_number(r)
  call gc2gm(glat*r,glon*r,gmlat,gmlon)
  if (modulo(i,100000) == 0) print '(2F8.2,A,2f8.2,A,I8)', glat, glon,' geographic => geomagnetic lat, lon ',gmlat, gmlon, ' iter',i
end do
call cpu_time(toc)
! --- end benchmark

print *, 'geomagnetic lat, lon (degrees) ',gmlat, gmlon
print *, (toc-tic)/N, ' seconds per conversion'

end program
