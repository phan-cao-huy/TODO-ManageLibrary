using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ManageLibrary.Models
{
    public partial class Employee
    {
        // EmployeeId: Bắt buộc, có thể yêu cầu độ dài tối đa
        [Required(ErrorMessage = "Mã nhân viên là bắt buộc.")]
        [StringLength(20, ErrorMessage = "Mã nhân viên không được vượt quá 20 ký tự.")]
        public string EmployeeId { get; set; } = null!;

        // FullName: Bắt buộc, không được chứa số, và có độ dài tối đa
        [Required(ErrorMessage = "Họ tên nhân viên là bắt buộc.")]
        [StringLength(100, ErrorMessage = "Họ tên không được vượt quá 100 ký tự.")]
        [RegularExpression(@"^[^\d]*$", ErrorMessage = "Họ tên nhân viên không được chứa số.")]
        public string FullName { get; set; } = null!;

        // Email: Không bắt buộc nhưng nếu có phải đúng định dạng email
        [EmailAddress(ErrorMessage = "Email không hợp lệ.")]
        public string? Email { get; set; }

        // Telephone: Không bắt buộc nhưng nếu có phải theo định dạng hợp lệ
        [Phone(ErrorMessage = "Số điện thoại không hợp lệ.")]
        public string? Telephone { get; set; }

        // Role: Có thể không bắt buộc nhưng nếu có thì phải là một giá trị hợp lệ
        [StringLength(50, ErrorMessage = "Vai trò không được vượt quá 50 ký tự.")]
        public string? Role { get; set; }

        // Navigation properties (không cần validate)
        [JsonIgnore]
        public virtual ICollection<Account> Accounts { get; set; } = new List<Account>();

        [JsonIgnore]
        public virtual ICollection<LoanSlip> LoanSlips { get; set; } = new List<LoanSlip>();

        [JsonIgnore]
        public virtual ICollection<ShiftAssignment> ShiftAssignments { get; set; } = new List<ShiftAssignment>();
    }
}
