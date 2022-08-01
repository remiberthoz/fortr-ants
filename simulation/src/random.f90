module random_mod
    implicit none
    private
    public jiggle_2d

contains

    subroutine random_normal_2d(output)
        real, dimension(:, :), intent(out) :: output
        real, dimension(size(output, dim=1), size(output, dim=2)) :: u1, u2
        call random_number(u1)
        call random_number(u2)
        output(:, :) = sqrt(-2*log(u1)) * cos(2*3.1415*u2)
    end subroutine random_normal_2d

    function jiggle_2d(input, a) result(output)
        real, dimension(:, :), intent(in) :: input
        real, intent(in) :: a
        real, dimension(size(input,dim=1), size(input,dim=2)) :: output
        real, dimension(size(input,dim=1), size(input,dim=2)) :: rnd
        call random_normal_2d(rnd)
        output(:, :) = input + rnd * a
    end function jiggle_2d

end module random_mod
