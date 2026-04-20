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
    public class LibraryCardController : Controller
    {
        private readonly ManageLibraryContext _context;

        public LibraryCardController(ManageLibraryContext context)
        {
            _context = context;
        }

        // GET: LibraryCard
        public async Task<IActionResult> Index(string? search)
        {
            ViewData["CurrentFilter"] = search;

            var query = _context.LibraryCards.Include(l => l.Reader).AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                var term = search.ToLower();
                query = query.Where(l =>
                    (l.CardId != null && l.CardId.ToLower().Contains(term)) ||
                    (l.Reader != null && l.Reader.FullName != null && l.Reader.FullName.ToLower().Contains(term)) ||
                    (l.Status != null && l.Status.ToLower().Contains(term))
                );
            }

            var libraryCards = await query.AsNoTracking().ToListAsync();
            return View(libraryCards);
        }

        // GET: LibraryCard/Details/5
        public async Task<IActionResult> Details(string id)
        {
            if (id == null) return NotFound();

            var libraryCard = await _context.LibraryCards
                .Include(l => l.Reader)
                .FirstOrDefaultAsync(m => m.CardId == id);
            if (libraryCard == null) return NotFound();

            return View(libraryCard);
        }

        // GET: LibraryCard/Create
        public IActionResult Create()
        {
            ViewData["ReaderId"] = GetReaderSelectList();
            return View();
        }

        // POST: LibraryCard/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ReaderId,IssueDate,ExpiryDate,Status,Notes")] LibraryCard libraryCard)
        {
            string newCardId;
            bool exists;
            var random = new Random();

            do
            {
                string msv = random.Next(1000, 9999).ToString();
                newCardId = "T" + msv;
                exists = await _context.LibraryCards.AnyAsync(r => r.CardId == newCardId);
            } while (exists);

            libraryCard.CardId = newCardId;

            bool readerHasCard = await _context.LibraryCards.AnyAsync(c => c.ReaderId == libraryCard.ReaderId);
            if (readerHasCard)
            {
                ModelState.AddModelError("ReaderId", "Độc giả này đã có thẻ thư viện.");
            }

            ModelState.Remove(nameof(libraryCard.CardId));
            ModelState.Remove(nameof(libraryCard.Reader));

            if (ModelState.IsValid)
            {
                _context.Add(libraryCard);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Đã thêm thẻ thư viện thành công.";
                return RedirectToAction(nameof(Index));
            }
            ViewData["ReaderId"] = GetReaderSelectList(libraryCard.ReaderId);
            return View(libraryCard);
        }

        // GET: LibraryCard/Edit/5
        public async Task<IActionResult> Edit(string id)
        {
            if (id == null) return NotFound();

            var libraryCard = await _context.LibraryCards.FindAsync(id);
            if (libraryCard == null) return NotFound();
            ViewData["ReaderId"] = GetReaderSelectList(libraryCard.ReaderId);
            return View(libraryCard);
        }

        // POST: LibraryCard/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, [Bind("CardId,ReaderId,IssueDate,ExpiryDate,Status,Notes")] LibraryCard libraryCard)
        {
            if (id != libraryCard.CardId) return NotFound();

            bool readerHasCard = await _context.LibraryCards.AnyAsync(c => c.ReaderId == libraryCard.ReaderId && c.CardId != id);
            if (readerHasCard)
            {
                ModelState.AddModelError("ReaderId", "Độc giả này đã có thẻ thư viện khác.");
            }

            ModelState.Remove(nameof(libraryCard.Reader));

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(libraryCard);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Cập nhật thẻ thư viện thành công.";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!LibraryCardExists(libraryCard.CardId)) return NotFound();
                    else throw;
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["ReaderId"] = GetReaderSelectList(libraryCard.ReaderId);
            return View(libraryCard);
        }

        // GET: LibraryCard/Delete/5
        public async Task<IActionResult> Delete(string id)
        {
            if (id == null) return NotFound();

            var libraryCard = await _context.LibraryCards
                .Include(l => l.Reader)
                .FirstOrDefaultAsync(m => m.CardId == id);
            if (libraryCard == null) return NotFound();

            return View(libraryCard);
        }

        // POST: LibraryCard/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            var libraryCard = await _context.LibraryCards.FindAsync(id);
            if (libraryCard != null)
            {
                _context.LibraryCards.Remove(libraryCard);
            }
            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Đã xóa thẻ thư viện thành công.";
            return RedirectToAction(nameof(Index));
        }

        private bool LibraryCardExists(string id)
        {
            return _context.LibraryCards.Any(e => e.CardId == id);
        }

        private SelectList GetReaderSelectList(object selectedValue = null)
        {
            var readers = _context.Readers.Select(r => new {
                ReaderId = r.ReaderId,
                DisplayText = r.ReaderId + " - " + r.FullName
            }).ToList();
            return new SelectList(readers, "ReaderId", "DisplayText", selectedValue);
        }
    }
}
