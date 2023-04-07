import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import SearchResultsLayout from '../components/SearchResultsLayout';

describe('SearchResultsLayout', () => {
  it('shows a message when there are no results', () => {
    render(<SearchResultsLayout params={{ query: 'foo' }} results={[]} vertical='web' />);
    const message = screen.getByText(/Please enter a search term in the box above./i);
    expect(message).toBeInTheDocument();
  });

  it('renders all relevant links', () => {
    render(<SearchResultsLayout params={{ query: 'foo' }} results={[]} vertical='web' />);
    const everything = screen.getByText(/More/i);
    const news = screen.getByText(/Related Sites/i);
    expect(everything).toBeInTheDocument();
    expect(news).toBeInTheDocument();
  });

  it('renders search results', () => {
    const results = [{ title: 'test result 1', url: 'https://www.search.gov', thumbnail: { url: 'https://www.search.gov/test_image.png' }, description: 'result body' }];
    render(<SearchResultsLayout params={{ query: 'foo' }} results={results} vertical='web' />);
    const resultTitle = screen.getByText(/test result 1/i);
    const resultUrl = screen.getByText(/https:\/\/www.search.gov/i);
    const resultBody = screen.getByText(/result body/i);
    expect(resultTitle).toBeInTheDocument();
    expect(resultUrl).toBeInTheDocument();
    expect(resultBody).toBeInTheDocument();
  });

  it('renders image search results', () => {
    const results = [{ title: 'test result 1', url: 'https://www.search.gov', thumbnail: { url: 'https://www.search.gov/test_image.png' }, description: 'result body' }];
    render(<SearchResultsLayout params={{ query: 'foo' }} results={results} vertical='image' />);
    const resultTitle = screen.getByText(/test result 1/i);
    const img = [...document.getElementsByClassName('result-image')].pop() as HTMLImageElement;
    expect(resultTitle).toBeInTheDocument();
    expect(img).toHaveAttribute('src', 'https://www.search.gov/test_image.png');
  });
});



