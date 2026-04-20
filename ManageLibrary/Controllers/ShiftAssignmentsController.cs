using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using ManageLibrary.Models;

namespace ManageLibrary.Controllers
{
    public class ShiftAssignmentsController : Controller
    {
        private readonly ManageLibraryContext _context;

        public ShiftAssignmentsController(ManageLibraryContext context)
        {
            _context = context;
        }

        // GET: ShiftAssignments
        public async Task<IActionResult> Index(DateTime? dateFilter)
        {
            var query = _context.ShiftAssignments
                .Include(s => s.Employee)
                .Include(s => s.Shift)
                .AsQueryable();

            if (dateFilter.HasValue)
            {
                query = query.Where(s => s.WorkDate == dateFilter.Value);
                ViewData["DateFilter"] = dateFilter.Value.ToString("yyyy-MM-dd");
            }

            var assignments = await query.OrderByDescending(s => s.WorkDate)
                                         .ThenBy(s => s.ShiftId)
                                         .ToListAsync();
            return View(assignments);
        }

        // GET: ShiftAssignments/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName");
            ViewData["ShiftId"] = new SelectList(_context.Shifts, "ShiftId", "ShiftName");
            return View();
        }

        // POST: ShiftAssignments/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("EmployeeId,ShiftId,WorkDate,Notes")] ShiftAssignment shiftAssignment)
        {
            if (ModelState.IsValid)
            {
                // Kiểm tra xem nhân viên đã có ca làm việc trong ngày này chưa (chống trùng lịch)
                bool isConflict = await _context.ShiftAssignments.AnyAsync(s => 
                    s.EmployeeId == shiftAssignment.EmployeeId && s.WorkDate == shiftAssignment.WorkDate);
                
                if (isConflict)
                {
                    ModelState.AddModelError("WorkDate", "Cảnh báo: Nhân viên đã có ca làm việc trong ngày này.");
                }
                else
                {
                    _context.Add(shiftAssignment);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Phân công ca làm việc thành công.";
                    return RedirectToAction(nameof(Index));
                }
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", shiftAssignment.EmployeeId);
            ViewData["ShiftId"] = new SelectList(_context.Shifts, "ShiftId", "ShiftName", shiftAssignment.ShiftId);
            return View(shiftAssignment);
        }

        // GET: ShiftAssignments/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();

            var shiftAssignment = await _context.ShiftAssignments
                .Include(s => s.Employee)
                .Include(s => s.Shift)
                .FirstOrDefaultAsync(m => m.AssignmentId == id);
            if (shiftAssignment == null) return NotFound();

            return View(shiftAssignment);
        }

        // POST: ShiftAssignments/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var shiftAssignment = await _context.ShiftAssignments.FindAsync(id);
            if (shiftAssignment != null)
            {
                _context.ShiftAssignments.Remove(shiftAssignment);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Xóa phân công ca thành công.";
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
