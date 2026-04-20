using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ManageLibrary.Models
{
    public partial class Shift
    {
        [Required]
        [StringLength(20)]
        [Display(Name = "Mã Ca")]
        public string ShiftId { get; set; } = null!;

        [Required(ErrorMessage = "Tên ca làm việc là bắt buộc.")]
        [StringLength(100)]
        [Display(Name = "Tên ca")]
        public string ShiftName { get; set; } = null!;

        [Required]
        [Display(Name = "Giờ bắt đầu")]
        public TimeSpan StartTime { get; set; }

        [Required]
        [Display(Name = "Giờ kết thúc")]
        public TimeSpan EndTime { get; set; }

        public virtual ICollection<ShiftAssignment> ShiftAssignments { get; set; } = new List<ShiftAssignment>();
    }
}
