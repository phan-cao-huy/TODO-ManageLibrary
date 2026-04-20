using System;
using System.ComponentModel.DataAnnotations;

namespace ManageLibrary.Models;

public partial class LibraryCard
{
    [Display(Name = "Mã Thẻ")]
    public string CardId { get; set; } = null!;

    [Display(Name = "Mã Độc Giả")]
    [Required(ErrorMessage = "Vui lòng chọn độc giả.")]
    public string ReaderId { get; set; } = null!;

    [Display(Name = "Ngày Cấp")]
    [Required(ErrorMessage = "Ngày cấp không được để trống.")]
    public DateOnly IssueDate { get; set; }

    [Display(Name = "Ngày Hết Hạn")]
    [Required(ErrorMessage = "Ngày hết hạn không được để trống.")]
    public DateOnly ExpiryDate { get; set; }

    [Display(Name = "Trạng Thái")]
    public string? Status { get; set; }

    [Display(Name = "Ghi Chú")]
    public string? Notes { get; set; }

    [Display(Name = "Độc Giả")]
    public virtual Reader? Reader { get; set; }
}
