using System;
using System.ComponentModel.DataAnnotations;

namespace ManageLibrary.Models
{
    public partial class ShiftAssignment
    {
        [Key]
        public int AssignmentId { get; set; }

        [Required]
        [Display(Name = "Nhân viên")]
        public string EmployeeId { get; set; } = null!;

        [Required]
        [Display(Name = "Ca làm việc")]
        public string ShiftId { get; set; } = null!;

        [Required(ErrorMessage = "Vui lòng chọn ngày trực.")]
        [DataType(DataType.Date)]
        [Display(Name = "Ngày trực")]
        public DateTime WorkDate { get; set; }

        [StringLength(200)]
        [Display(Name = "Ghi chú")]
        public string? Notes { get; set; }

        public virtual Employee? Employee { get; set; }
        public virtual Shift? Shift { get; set; }
    }
}
