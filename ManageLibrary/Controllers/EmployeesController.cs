using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using ManageLibrary.Models;

namespace ManageLibrary.Controllers
{
    public class EmployeesController : Controller
    {
        private readonly ManageLibraryContext _context;

        public EmployeesController(ManageLibraryContext context)
        {
            _context = context;
        }

        // GET: Employees
        public async Task<IActionResult> Index(string? search)
        {
            ViewData["CurrentFilter"] = search;

            var query = _context.Employees.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.ToLower();
                query = query.Where(e =>
                    (e.EmployeeId != null && e.EmployeeId.ToLower().Contains(term)) ||
                    (e.FullName != null && e.FullName.ToLower().Contains(term)) ||
                    (e.Email != null && e.Email.ToLower().Contains(term)) ||
                    (e.Telephone != null && e.Telephone.ToLower().Contains(term)) ||
                    (e.Role != null && e.Role.ToLower().Contains(term))
                );
            }

            var employees = await query.AsNoTracking().ToListAsync();
            return View(employees);
        }

        // GET: Employees/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (id == null) return NotFound();

            var employee = await _context.Employees
                .FirstOrDefaultAsync(m => m.EmployeeId == id);
            if (employee == null) return NotFound();

            return View(employee);
        }

        // GET: Employees/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Employees/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("FullName,Email,Telephone,Role")] Employee employee)
        {
            string newEmployeeId;
            bool exists;
            var random = new Random();

            do
            {
                string num = random.Next(100, 999).ToString();
                newEmployeeId = "NV" + num;
                exists = await _context.Employees.AnyAsync(e => e.EmployeeId == newEmployeeId);
            } while (exists);

            employee.EmployeeId = newEmployeeId;

            ModelState.Remove(nameof(employee.EmployeeId));

            if (ModelState.IsValid)
            {
                _context.Add(employee);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Đã thêm nhân viên thành công.";
                return RedirectToAction(nameof(Index));
            }
            return View(employee);
        }

        // GET: Employees/Edit/5
        public async Task<IActionResult> Edit(string id)
        {
            if (id == null) return NotFound();

            var employee = await _context.Employees.FindAsync(id);
            if (employee == null) return NotFound();
            return View(employee);
        }

        // POST: Employees/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, [Bind("EmployeeId,FullName,Email,Telephone,Role")] Employee employee)
        {
            if (id != employee.EmployeeId) return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(employee);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Cập nhật nhân viên thành công.";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!EmployeeExists(employee.EmployeeId)) return NotFound();
                    else throw;
                }
                return RedirectToAction(nameof(Index));
            }
            return View(employee);
        }

        // POST: Employees/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            // Cần kiểm tra xem nhân viên có đang lập phiếu mượn nào không
            bool hasLoanSlips = await _context.LoanSlips.AnyAsync(ls => ls.EmployeeId == id);
            
            if (hasLoanSlips)
            {
                TempData["ErrorMessage"] = "Không thể xóa nhân viên này vì đã tham gia tạo phiếu mượn trả.";
                return RedirectToAction(nameof(Index));
            }

            var employee = await _context.Employees.FindAsync(id);
            if (employee != null)
            {
                // Remove accounts related to this employee
                var accounts = _context.Accounts.Where(a => a.EmployeeId == id);
                _context.Accounts.RemoveRange(accounts);
                
                _context.Employees.Remove(employee);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Đã xóa nhân viên thành công.";
            }
            return RedirectToAction(nameof(Index));
        }

        private bool EmployeeExists(string id)
        {
            return _context.Employees.Any(e => e.EmployeeId == id);
        }
    }
}
